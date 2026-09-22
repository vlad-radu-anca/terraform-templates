locals {
  cluster_identifier = coalesce(var.cluster_identifier, "${var.project_name}-${var.environment}-aurora")

  default_ports = {
    aurora-mysql      = 3306
    aurora-postgresql = 5432
  }
  port = coalesce(var.port, local.default_ports[var.engine])

  default_log_exports = {
    aurora-mysql      = ["audit", "error", "general", "slowquery"]
    aurora-postgresql = ["postgresql"]
  }
  log_exports = var.enabled_cloudwatch_logs_exports != null ? var.enabled_cloudwatch_logs_exports : local.default_log_exports[var.engine]

  create_subnet_group            = var.db_subnet_group_name == null
  create_security_group          = length(var.vpc_security_group_ids) == 0
  create_cluster_parameter_group = var.db_cluster_parameter_group_name == null && length(var.cluster_parameters) > 0
  create_db_parameter_group      = var.db_parameter_group_name == null && length(var.instance_parameters) > 0
  create_monitoring_role         = var.monitoring_interval > 0 && var.monitoring_role_arn == null

  # Serverless v2 instances use the reserved "db.serverless" class.
  serverless_enabled = var.serverlessv2_scaling != null

  security_group_ids = local.create_security_group ? [aws_security_group.this[0].id] : var.vpc_security_group_ids

  tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags,
  )
}

########################################
# Networking
########################################

resource "aws_db_subnet_group" "this" {
  count = local.create_subnet_group ? 1 : 0

  name       = local.cluster_identifier
  subnet_ids = var.subnet_ids

  tags = merge(local.tags, { Name = "${local.cluster_identifier}-subnet-group" })
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = "${local.cluster_identifier}-db"
  description = "Access to ${local.cluster_identifier} (${var.engine}) on port ${local.port}"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${local.cluster_identifier}-db" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = local.create_security_group ? toset(var.allowed_cidr_blocks) : toset([])

  security_group_id = aws_security_group.this[0].id
  description       = "Database access from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = local.port
  to_port           = local.port
  ip_protocol       = "tcp"

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  for_each = local.create_security_group ? toset(var.allowed_security_group_ids) : toset([])

  security_group_id            = aws_security_group.this[0].id
  description                  = "Database access from ${each.value}"
  referenced_security_group_id = each.value
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "all" {
  count = local.create_security_group ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = local.tags
}

########################################
# Parameter groups
########################################

resource "aws_rds_cluster_parameter_group" "this" {
  count = local.create_cluster_parameter_group ? 1 : 0

  name_prefix = "${local.cluster_identifier}-cluster-"
  family      = var.parameter_group_family
  description = "Cluster parameters for ${local.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "this" {
  count = local.create_db_parameter_group ? 1 : 0

  name_prefix = "${local.cluster_identifier}-instance-"
  family      = var.parameter_group_family
  description = "Instance parameters for ${local.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

########################################
# Enhanced monitoring role
########################################

data "aws_iam_policy_document" "monitoring_assume" {
  count = local.create_monitoring_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  name_prefix        = "${local.cluster_identifier}-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

########################################
# Cluster
########################################

resource "aws_rds_cluster" "this" {
  cluster_identifier = local.cluster_identifier

  engine         = var.engine
  engine_mode    = var.engine_mode
  engine_version = var.engine_version
  database_name  = var.database_name
  port           = local.port

  master_username                     = var.snapshot_identifier == null ? var.master_username : null
  manage_master_user_password         = var.manage_master_user_password ? true : null
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  master_password                     = var.manage_master_user_password ? null : var.master_password
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles

  db_subnet_group_name            = local.create_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  vpc_security_group_ids          = local.security_group_ids
  availability_zones              = var.availability_zones
  db_cluster_parameter_group_name = local.create_cluster_parameter_group ? aws_rds_cluster_parameter_group.this[0].name : var.db_cluster_parameter_group_name

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id
  storage_type      = var.storage_type

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot
  backtrack_window             = var.backtrack_window

  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${local.cluster_identifier}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  snapshot_identifier         = var.snapshot_identifier
  apply_immediately           = var.apply_immediately
  allow_major_version_upgrade = var.allow_major_version_upgrade

  enabled_cloudwatch_logs_exports = local.log_exports
  enable_http_endpoint            = var.enable_http_endpoint

  global_cluster_identifier     = var.global_cluster_identifier
  replication_source_identifier = var.replication_source_identifier
  source_region                 = var.source_region

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.serverless_enabled ? [var.serverlessv2_scaling] : []
    content {
      min_capacity             = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity             = serverlessv2_scaling_configuration.value.max_capacity
      seconds_until_auto_pause = serverlessv2_scaling_configuration.value.seconds_until_auto_pause
    }
  }

  tags = merge(local.tags, { Name = local.cluster_identifier })

  lifecycle {
    # The final snapshot name embeds a plan-time timestamp; ignore it to avoid a perpetual diff.
    ignore_changes = [final_snapshot_identifier]
  }
}

########################################
# Cluster instances
########################################

resource "aws_rds_cluster_instance" "this" {
  for_each = var.instances

  identifier         = "${local.cluster_identifier}-${each.key}"
  cluster_identifier = aws_rds_cluster.this.id

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
  instance_class = local.serverless_enabled ? "db.serverless" : coalesce(each.value.instance_class, var.instance_class)

  db_subnet_group_name    = aws_rds_cluster.this.db_subnet_group_name
  db_parameter_group_name = local.create_db_parameter_group ? aws_db_parameter_group.this[0].name : var.db_parameter_group_name

  publicly_accessible        = var.publicly_accessible
  availability_zone          = each.value.availability_zone
  promotion_tier             = each.value.promotion_tier
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  ca_cert_identifier         = var.ca_cert_identifier
  apply_immediately          = var.apply_immediately
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = local.create_monitoring_role ? aws_iam_role.monitoring[0].arn : var.monitoring_role_arn

  tags = merge(local.tags, each.value.tags, { Name = "${local.cluster_identifier}-${each.key}" })
}
