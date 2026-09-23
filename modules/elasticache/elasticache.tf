resource "aws_elasticache_subnet_group" "this" {
  count       = var.elasticache_subnet_group_name != null ? 1 : 0
  name        = var.elasticache_subnet_group_name
  description = var.description
  subnet_ids  = var.subnet_ids
}

resource "aws_elasticache_cluster" "this" {
  count                        = var.cluster_id != null ? 1 : 0
  cluster_id                   = var.cluster_id
  replication_group_id         = var.replication_group_id
  engine                       = var.engine
  engine_version               = var.engine_version
  maintenance_window           = var.maintenance_window
  node_type                    = var.node_type
  num_cache_nodes              = var.num_cache_nodes
  parameter_group_name         = var.parameter_group_name
  port                         = var.port
  subnet_group_name            = var.subnet_group_name
  security_group_ids           = var.security_group_ids
  apply_immediately            = var.apply_immediately
  snapshot_arns                = var.snapshot_arns
  snapshot_name                = var.snapshot_name
  snapshot_window              = var.snapshot_window
  snapshot_retention_limit     = var.snapshot_retention_limit
  notification_topic_arn       = var.notification_topic_arn
  az_mode                      = var.az_mode
  availability_zone            = var.availability_zone
  preferred_availability_zones = var.preferred_availability_zones
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${var.cluster_id}-elasticache_cluster"
  }
}