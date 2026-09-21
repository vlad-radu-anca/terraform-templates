locals {
  identifier = coalesce(var.identifier, "${var.project_name}-${var.environment}-${var.engine}")

  default_ports = {
    postgres = 5432
    mysql    = 3306
    mariadb  = 3306
  }
  port = coalesce(var.port, local.default_ports[var.engine])

  default_log_exports = {
    postgres = ["postgresql", "upgrade"]
    mysql    = ["error", "general", "slowquery"]
    mariadb  = ["error", "general", "slowquery"]
  }
  log_exports = var.enabled_cloudwatch_logs_exports != null ? var.enabled_cloudwatch_logs_exports : local.default_log_exports[var.engine]

  create_subnet_group    = var.db_subnet_group_name == null
  create_parameter_group = var.parameter_group_name == null && length(var.parameters) > 0
  create_option_group    = var.option_group_name == null && length(var.options) > 0 && var.engine != "postgres"
  create_monitoring_role = var.monitoring_interval > 0

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

  name       = local.identifier
  subnet_ids = var.subnet_ids

  tags = merge(local.tags, { Name = "${local.identifier}-subnet-group" })
}

resource "aws_security_group" "this" {
  name        = "${local.identifier}-db"
  description = "Access to ${local.identifier} (${var.engine}) on port ${local.port}"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${local.identifier}-db" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  description       = "Database access from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = local.port
  to_port           = local.port
  ip_protocol       = "tcp"

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  description                  = "Database access from ${each.value}"
  referenced_security_group_id = each.value
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = local.tags
}

########################################
# Parameter / option groups
########################################

resource "aws_db_parameter_group" "this" {
  count = local.create_parameter_group ? 1 : 0

  name_prefix = "${local.identifier}-"
  family      = var.parameter_group_family
  description = "Parameters for ${local.identifier}"

  dynamic "parameter" {
    for_each = var.parameters
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

resource "aws_db_option_group" "this" {
  count = local.create_option_group ? 1 : 0

  name_prefix              = "${local.identifier}-"
  engine_name              = var.engine
  major_engine_version     = var.option_group_engine_version
  option_group_description = "Options for ${local.identifier}"

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.key
      port                           = option.value.port
      version                        = option.value.version
      db_security_group_memberships  = option.value.db_security_group_memberships
      vpc_security_group_memberships = option.value.vpc_security_group_memberships

      dynamic "option_settings" {
        for_each = option.value.settings
        content {
          name  = option_settings.key
          value = option_settings.value
        }
      }
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

  name_prefix        = "${local.identifier}-rds-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

########################################
# Primary instance
########################################

resource "aws_db_instance" "this" {
  identifier = local.identifier

  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  port                        = local.port
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  ca_cert_identifier          = var.ca_cert_identifier

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  iops                  = var.iops
  storage_throughput    = var.storage_throughput
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name                             = var.db_name
  username                            = var.snapshot_identifier == null ? var.username : null
  manage_master_user_password         = var.manage_master_user_password ? true : null
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  password                            = var.manage_master_user_password ? null : var.password
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  snapshot_identifier                 = var.snapshot_identifier

  db_subnet_group_name   = local.create_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  vpc_security_group_ids = concat([aws_security_group.this.id], var.additional_security_group_ids)
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone
  network_type           = var.network_type

  parameter_group_name = local.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name
  option_group_name    = local.create_option_group ? aws_db_option_group.this[0].name : var.option_group_name

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${local.identifier}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  apply_immediately         = var.apply_immediately

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = local.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null
  enabled_cloudwatch_logs_exports       = local.log_exports

  tags = merge(local.tags, { Name = local.identifier })

  lifecycle {
    # The final snapshot name embeds a timestamp evaluated at plan time; ignore it to avoid perpetual diffs.
    ignore_changes = [final_snapshot_identifier]
  }
}

########################################
# Read replicas
########################################

resource "aws_db_instance" "replica" {
  count = var.replica_count

  identifier          = "${local.identifier}-replica-${count.index + 1}"
  replicate_source_db = aws_db_instance.this.identifier

  instance_class             = coalesce(var.replica_instance_class, var.instance_class)
  port                       = local.port
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  ca_cert_identifier         = var.ca_cert_identifier

  # Storage, engine, credentials and subnet group are inherited from the source in the same region.
  storage_type       = var.storage_type
  iops               = var.iops
  storage_throughput = var.storage_throughput
  storage_encrypted  = var.storage_encrypted
  kms_key_id         = var.kms_key_id

  vpc_security_group_ids = concat([aws_security_group.this.id], var.additional_security_group_ids)
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.replica_multi_az
  network_type           = var.network_type

  parameter_group_name = local.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name

  backup_retention_period = 0
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = true
  apply_immediately       = var.apply_immediately

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = local.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null
  enabled_cloudwatch_logs_exports       = local.log_exports

  tags = merge(local.tags, { Name = "${local.identifier}-replica-${count.index + 1}" })
}
