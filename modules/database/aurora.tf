
resource "aws_db_subnet_group" "this" {
  count                = var.db_subnet_group_name != null ? 1:0
  name       = "${var.db_subnet_group_name}"
  subnet_ids = var.subnet_ids

    tags = {
        Terraform                       = true
        Environment                     = var.environment
        Name                            = "${var.db_subnet_group_name}-db_subnet_group"
    }
}

resource "aws_rds_cluster_instance" "this" {
    depends_on = [ "aws_db_subnet_group.this", "aws_rds_cluster.this" ]
    count                = var.identifier != null ? 1:0
    identifier = "${var.identifier}"
    identifier_prefix = var.identifier_prefix
    cluster_identifier = var.rds_cluster_instance_cluster_identifier
    engine = var.rds_cluster_instance_engine
    engine_version = var.rds_cluster_instance_engine_version
    instance_class = var.instance_class
    publicly_accessible = var.publicly_accessible
    db_subnet_group_name = var.rds_cluster_instance_db_subnet_group_name
    db_parameter_group_name = var.db_parameter_group_name
    apply_immediately = var.rds_cluster_instance_apply_immediately
    monitoring_role_arn = var.monitoring_role_arn
    monitoring_interval = var.monitoring_interval
    promotion_tier = var.promotion_tier
    availability_zone = var.availability_zone
    preferred_backup_window = var.preferred_backup_window
    preferred_maintenance_window = var.rds_cluster_instance_preferred_maintenance_window
    auto_minor_version_upgrade = var.auto_minor_version_upgrade
    performance_insights_enabled = var.performance_insights_enabled
    performance_insights_kms_key_id = var.performance_insights_kms_key_id
    copy_tags_to_snapshot = var.rds_cluster_instance_copy_tags_to_snapshot
    ca_cert_identifier = var.ca_cert_identifier
    tags = {
        Terraform                       = true
        Environment                     = var.environment
        Name                            = "${var.identifier}-rds_cluster_instance"
    }
}

resource "aws_rds_cluster" "this" {
    depends_on = [ "aws_db_subnet_group.this" ]
    count                = var.rds_cluster_identifier != null ? 1:0
    allow_major_version_upgrade = var.allow_major_version_upgrade
    apply_immediately = var.rds_cluster_apply_immediately
    availability_zones = var.availability_zones
    backtrack_window = var.backtrack_window
    backup_retention_period = var.backup_retention_period
    cluster_identifier_prefix = var.cluster_identifier_prefix
    cluster_identifier = "${var.rds_cluster_identifier}"
    copy_tags_to_snapshot = var.rds_cluster_copy_tags_to_snapshot
    database_name = var.database_name
    db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
    db_subnet_group_name = var.rds_cluster_db_subnet_group_name
    deletion_protection = var.deletion_protection
    enable_http_endpoint = var.enable_http_endpoint
    enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
    engine_mode = var.engine_mode
    engine_version = var.rds_cluster_engine_version
    engine = var.rds_cluster_engine
    final_snapshot_identifier = var.final_snapshot_identifier
    global_cluster_identifier = var.global_cluster_identifier
    iam_database_authentication_enabled = var.iam_database_authentication_enabled
    iam_roles = var.iam_roles
    kms_key_id = var.kms_key_id
    master_password = var.master_password
    master_username = var.master_username
    port = var.port
    preferred_maintenance_window = var.rds_cluster_preferred_maintenance_window
    replication_source_identifier = var.replication_source_identifier

    dynamic "scaling_configuration" {
        for_each = var.scaling_configuration
        content {
            auto_pause = scaling_configuration.value.auto_pause
            max_capacity = scaling_configuration.value.max_capacity
            min_capacity = scaling_configuration.value.min_capacity
            seconds_until_auto_pause = scaling_configuration.value.seconds_until_auto_pause
            timeout_action = scaling_configuration.value.timeout_action
        }
    }
    skip_final_snapshot = var.skip_final_snapshot
    snapshot_identifier = var.snapshot_identifier
    source_region = var.source_region
    storage_encrypted = var.storage_encrypted
    vpc_security_group_ids = var.vpc_security_group_ids 
    
    tags = {
        Terraform                       = true
        Environment                     = var.environment
        Name                            = "${var.rds_cluster_identifier}-rds_cluster"
    }
      
}