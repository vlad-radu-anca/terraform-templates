variable "db_subnet_group_name" {
  description = "The name of the DB subnet group. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}
variable "subnet_ids" {
  description = "A list of VPC subnet IDs."
  type        = set(string)
  default     = null
}

variable "identifier" {
  description = "The identifier for the RDS instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "identifier_prefix" {
  description = "Creates a unique identifier beginning with the specified prefix. Conflicts with identifier."
  type        = string
  default     = null
}

variable "rds_cluster_instance_cluster_identifier" {
  description = " The identifier of the aws_rds_cluster in which to launch this instance."
  type        = string
  default     = null
}

variable "rds_cluster_instance_engine" {
  description = "The name of the database engine to be used for the RDS instance. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql"
  type        = string
  default     = null
}

variable "rds_cluster_instance_engine_version" {
  description = "The database engine version. "
  type        = string
  default     = null
}

variable "instance_class" {
  description = " The instance class to use. "
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible. Default false"
  type        = bool
  default     = false
}

variable "rds_cluster_instance_db_subnet_group_name" {
  description = "(Required if publicly_accessible = false, Optional otherwise) A DB subnet group to associate with this DB instance. "
  type        = string
  default     = null
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group to associate with this instance."
  type        = string
  default     = null
}

variable "rds_cluster_instance_apply_immediately" {
  description = " Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default isfalse."
  type        = bool
  default     = false
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. You can find more information on the"
  type        = string
  default     = null
}
variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0."
  type        = number
  default     = null
}

variable "promotion_tier" {
  description = "Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoted to writer."
  type        = number
  default     = null
}

variable "availability_zone" {
  description = "The daily time range during which automated backups are created if automated backups are enabled. Eg: '04:00-09:00'"
  type        = string
  default     = null
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled. Eg: '04:00-09:00'"
  type        = string
  default     = null
}

variable "rds_cluster_instance_preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "ndicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true."
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "pecifies whether Performance Insights is enabled or not."
  type        = bool
  default     = null
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data. When specifying"
  type        = string
  default     = null
}

variable "rds_cluster_instance_copy_tags_to_snapshot" {
  description = " Indicates whether to copy all of the user-defined tags from the DB instance to snapshots of the DB instance. Default false."
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  type        = string
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to false."
  type        = bool
  default     = false
}

variable "rds_cluster_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "A list of EC2 Availability Zones for the DB cluster storage where DB cluster instances can be created."
  type        = list(string)
  default     = null
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Only available for aurora engine currently. To disable backtracking, set this value to 0. Defaults to 0. Must be between 0 and 259200 (72 hours)"
  type        = number
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default 1"
  type        = number
  default     = null
}

variable "cluster_identifier_prefix" {
  description = "description"
  type        = string
  default     = null
}

variable "rds_cluster_identifier" {
  description = "The cluster identifier. If omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "rds_cluster_copy_tags_to_snapshot" {
  description = "Copy all Cluster tags to snapshots. Default is false."
  type        = bool
  default     = false
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation."
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster."
  type        = string
  default     = null
}

variable "rds_cluster_db_subnet_group_name" {
  description = " A DB subnet group to associate with this DB instance. NOTE: This must match the db_subnet_group_name specified on every aws_rds_cluster_instance in the cluster."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
  type        = bool
  default     = false
}

variable "enable_http_endpoint" {
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to serverless."
  type        = bool
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql"
  type        = set(string)
  default     = null
}


variable "engine_mode" {
  description = "The database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), multimaster, parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless"
  type        = string
  default     = null
}

variable "rds_cluster_engine_version" {
  description = "The database engine version. Updating this argument results in an outage."
  type        = string
  default     = null
}

variable "rds_cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql"
  type        = string
  default     = null
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "global_cluster_identifier" {
  description = "The global cluster identifier specified on aws_rds_global_cluster."
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Please see AWS Documentation for availability and limitations."
  type        = string
  default     = null
}


variable "iam_roles" {
  description = "A List of ARNs for the IAM roles to associate to the RDS Cluster."
  type        = list(string)
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true."
  type        = string
  default     = null
}

variable "master_password" {
  description = "(Required unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the 'secondary' cluster of a global database) Password for the master DB user. "
  type        = string
  default     = null
}

variable "master_username" {
  description = " (Required unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the 'secondary' cluster of a global database) Username for the master DB user."
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "rds_cluster_preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC) e.g. wed:04:00-wed:04:30"
  type        = string
  default     = null
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. "
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = "Nested attribute for point in time restore."
  type = list(object({
    source_cluster_identifier  = string
    restore_type               = string
    use_latest_restorable_time = bool
  }))
  default = []
}

variable "scaling_configuration" {
  description = "Nested attribute with scaling properties. Only valid when engine_mode is set to serverless"
  type = list(object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  }))
  default = []
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  type        = bool
  default     = null
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = string
  default     = null
}

variable "source_region" {
  description = "The source region for an encrypted replica DB cluster."
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is false for provisioned engine_mode and true for serverless engine_mode"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the Cluster"
  type        = list(string)
  default     = null
}

variable "ecr_lifecycle_policy_file" {
  description = "File path for ECR  Life Cycle Policy"
  type        = string
  default     = null
}

variable "aws_ecr_repository_policy_file" {
  description = "File path for ECR Repository Policy"
  type        = string
  default     = null
}


variable "environment" {
  type        = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default     = "testing"
}

variable "project_name" {
  type        = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default     = "asgard-infra-templates"
}