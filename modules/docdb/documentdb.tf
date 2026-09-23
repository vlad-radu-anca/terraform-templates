resource "aws_docdb_subnet_group" "this" {
  count       = var.db_subnet_group_name != null ? 1 : 0
  name        = var.db_subnet_group_name
  description = var.description
  subnet_ids  = var.subnet_ids
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.db_subnet_group_name}-docdb_db_subnet_group_name"
  }
}

resource "aws_docdb_cluster_instance" "this" {
  depends_on                   = ["aws_docdb_subnet_group.this", "aws_docdb_cluster.this"]
  count                        = var.instance_indetifier != null ? 1 : 0
  apply_immediately            = var.docdb_instance_apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  availability_zone            = var.availability_zone
  cluster_identifier           = var.cluster_identifier
  engine                       = var.docdb_instance_engine
  identifier                   = var.instance_indetifier
  instance_class               = var.instance_class
  preferred_maintenance_window = var.preferred_maintenance_window
  promotion_tier               = var.promotion_tier
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.instance_indetifier}-docdb_cluster_instance"
  }
}

resource "aws_docdb_cluster" "this" {
  depends_on                      = ["aws_docdb_subnet_group.this"]
  count                           = var.cluster_identifier != null ? 1 : 0
  apply_immediately               = var.docdb_cluster_apply_immediately
  availability_zones              = var.availability_zones
  backup_retention_period         = var.backup_retention_period
  cluster_identifier              = var.cluster_identifier
  db_subnet_group_name            = var.db_subnet_group_name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  engine                          = var.docdb_cluster_engine
  engine_version                  = var.engine_version
  final_snapshot_identifier       = var.final_snapshot_identifier
  kms_key_id                      = var.kms_key_id
  master_password                 = var.master_password
  master_username                 = var.master_username
  port                            = var.port
  preferred_backup_window         = var.preferred_backup_window
  skip_final_snapshot             = var.skip_final_snapshot
  snapshot_identifier             = var.snapshot_identifier
  storage_encrypted               = var.storage_encrypted
  vpc_security_group_ids          = var.vpc_security_group_ids
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.cluster_identifier}-docdb_cluster"
  }
}