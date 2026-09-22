locals {
  domain_name = coalesce(var.domain_name, "${var.project_name}-${var.environment}")

  in_vpc                = length(var.subnet_ids) > 0
  create_security_group = local.in_vpc && length(var.security_group_ids) == 0
  security_group_ids    = local.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids

  # Zone awareness needs at least two subnets, and the AZ count must match what is supplied.
  zone_awareness_enabled = local.in_vpc && length(var.subnet_ids) > 1

  create_log_groups = { for t in var.published_log_types : t => t if var.create_log_groups }

  # Whether FGAC is on is not itself a secret, but the variable is sensitive,
  # so unwrap just this check to keep it usable in for_each.
  fgac_enabled = nonsensitive(var.fine_grained_access_control != null)

  tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags,
  )
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

########################################
# Networking
########################################

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = "${local.domain_name}-opensearch"
  description = "HTTPS access to the ${local.domain_name} OpenSearch domain"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${local.domain_name}-opensearch" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = local.create_security_group ? toset(var.allowed_cidr_blocks) : toset([])

  security_group_id = aws_security_group.this[0].id
  description       = "HTTPS from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  for_each = local.create_security_group ? toset(var.allowed_security_group_ids) : toset([])

  security_group_id            = aws_security_group.this[0].id
  description                  = "HTTPS from ${each.value}"
  referenced_security_group_id = each.value
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  tags = local.tags
}

########################################
# Log publishing
########################################

resource "aws_cloudwatch_log_group" "this" {
  for_each = local.create_log_groups

  name              = "/aws/opensearch/${local.domain_name}/${lower(each.value)}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_kms_key_id

  tags = local.tags
}

data "aws_iam_policy_document" "logs" {
  count = length(local.create_log_groups) > 0 ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["opensearchservice.amazonaws.com"]
    }
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch/${local.domain_name}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

# Without this resource policy the service cannot write to the log groups and
# the domain comes up with logging silently disabled.
resource "aws_cloudwatch_log_resource_policy" "this" {
  count = length(local.create_log_groups) > 0 ? 1 : 0

  policy_name     = "${local.domain_name}-opensearch-logs"
  policy_document = data.aws_iam_policy_document.logs[0].json
}

########################################
# Domain
########################################

resource "aws_opensearch_domain" "this" {
  domain_name    = local.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count

    zone_awareness_enabled = local.zone_awareness_enabled
    dynamic "zone_awareness_config" {
      for_each = local.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = length(var.subnet_ids)
      }
    }

    dedicated_master_enabled = var.dedicated_master.enabled
    dedicated_master_type    = var.dedicated_master.enabled ? var.dedicated_master.instance_type : null
    dedicated_master_count   = var.dedicated_master.enabled ? var.dedicated_master.count : null

    warm_enabled = var.warm_storage.enabled
    warm_type    = var.warm_storage.enabled ? var.warm_storage.instance_type : null
    warm_count   = var.warm_storage.enabled ? var.warm_storage.count : null

    multi_az_with_standby_enabled = var.multi_az_with_standby_enabled
  }

  ebs_options {
    ebs_enabled = var.ebs.enabled
    volume_size = var.ebs.enabled ? var.ebs.volume_size : null
    volume_type = var.ebs.enabled ? var.ebs.volume_type : null
    iops        = var.ebs.enabled ? var.ebs.iops : null
    throughput  = var.ebs.enabled ? var.ebs.throughput : null
  }

  # Encryption and HTTPS are on by default rather than opt-in.
  encrypt_at_rest {
    enabled    = var.encrypt_at_rest
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption
  }

  domain_endpoint_options {
    enforce_https                   = var.enforce_https
    tls_security_policy             = var.tls_security_policy
    custom_endpoint_enabled         = var.custom_endpoint != null
    custom_endpoint                 = try(var.custom_endpoint.name, null)
    custom_endpoint_certificate_arn = try(var.custom_endpoint.certificate_arn, null)
  }

  dynamic "vpc_options" {
    for_each = local.in_vpc ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = local.security_group_ids
    }
  }

  # for_each cannot take a sensitive value, so gate on a plain flag and read the
  # object directly inside the block.
  dynamic "advanced_security_options" {
    for_each = local.fgac_enabled ? [1] : []
    content {
      enabled                        = true
      anonymous_auth_enabled         = var.fine_grained_access_control.anonymous_auth_enabled
      internal_user_database_enabled = var.fine_grained_access_control.master_user_name != null

      master_user_options {
        master_user_arn      = var.fine_grained_access_control.master_user_arn
        master_user_name     = var.fine_grained_access_control.master_user_name
        master_user_password = var.fine_grained_access_control.master_user_password
      }
    }
  }

  dynamic "log_publishing_options" {
    for_each = toset(var.published_log_types)
    content {
      log_type = log_publishing_options.value
      cloudwatch_log_group_arn = var.create_log_groups ? aws_cloudwatch_log_group.this[log_publishing_options.value].arn : lookup(
        var.existing_log_group_arns, log_publishing_options.value, null
      )
      enabled = true
    }
  }

  auto_tune_options {
    desired_state       = var.auto_tune_enabled ? "ENABLED" : "DISABLED"
    rollback_on_disable = var.auto_tune_enabled ? null : "NO_ROLLBACK"
    use_off_peak_window = var.auto_tune_enabled ? var.off_peak_window_enabled : null
  }

  off_peak_window_options {
    enabled = var.off_peak_window_enabled

    dynamic "off_peak_window" {
      for_each = var.off_peak_window_start_hour == null ? [] : [1]
      content {
        window_start_time {
          hours   = var.off_peak_window_start_hour
          minutes = 0
        }
      }
    }
  }

  software_update_options {
    auto_software_update_enabled = var.auto_software_update_enabled
  }

  advanced_options = var.advanced_options
  access_policies  = var.access_policies
  ip_address_type  = var.ip_address_type

  dynamic "snapshot_options" {
    for_each = var.automated_snapshot_start_hour == null ? [] : [1]
    content {
      automated_snapshot_start_hour = var.automated_snapshot_start_hour
    }
  }

  tags = merge(local.tags, { Name = local.domain_name })

  depends_on = [aws_cloudwatch_log_resource_policy.this]
}
