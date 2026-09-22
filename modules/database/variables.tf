########################################
# Naming / tagging
########################################

variable "project_name" {
  description = "Name of the application/project, used as a prefix when naming resources."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod), used as a prefix when naming resources."
  type        = string
}

variable "cluster_identifier" {
  description = "Cluster identifier. Defaults to `<project_name>-<environment>-aurora`."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}

########################################
# Engine
########################################

variable "engine" {
  description = "Aurora engine: `aurora-mysql` or `aurora-postgresql`."
  type        = string
  default     = "aurora-postgresql"

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "engine must be aurora-mysql or aurora-postgresql."
  }
}

variable "engine_mode" {
  description = "Engine mode. Use `provisioned` for both provisioned and Serverless v2 clusters. `serverless` is Aurora Serverless v1 and is legacy."
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "Engine version, e.g. `16.4` for Aurora PostgreSQL or `8.0.mysql_aurora.3.08.0` for Aurora MySQL. Null uses the AWS default."
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name of the initial database created with the cluster."
  type        = string
  default     = null
}

variable "port" {
  description = "Port the cluster listens on. Defaults to 5432 for Aurora PostgreSQL, 3306 for Aurora MySQL."
  type        = number
  default     = null
}

variable "allow_major_version_upgrade" {
  description = "Allow major engine version upgrades when `engine_version` changes."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Apply minor engine upgrades automatically during the maintenance window."
  type        = bool
  default     = true
}

variable "ca_cert_identifier" {
  description = "Identifier of the CA certificate for the instances, e.g. `rds-ca-rsa2048-g1`. Null keeps the RDS default."
  type        = string
  default     = null
}

########################################
# Instances
########################################

variable "instances" {
  description = <<-EOT
  Cluster instances keyed by suffix. The key becomes part of the instance identifier, e.g. `{ writer = {}, reader-1 = {} }`.
  `promotion_tier` 0 or 1 makes an instance a preferred failover target. `instance_class` overrides the cluster default
  and is ignored when `serverlessv2_scaling` is set, because Serverless v2 requires `db.serverless`.
  EOT
  type = map(object({
    instance_class    = optional(string)
    availability_zone = optional(string)
    promotion_tier    = optional(number, 1)
    tags              = optional(map(string), {})
  }))
  default = {
    writer = { promotion_tier = 0 }
  }
}

variable "instance_class" {
  description = "Default instance class for cluster instances, e.g. `db.r6g.large`. Ignored when `serverlessv2_scaling` is set."
  type        = string
  default     = "db.t4g.medium"
}

variable "serverlessv2_scaling" {
  description = <<-EOT
  Aurora Serverless v2 scaling. When set, every instance uses `db.serverless` and scales between the given ACU bounds.
  `seconds_until_auto_pause` (300 to 86400) scales the cluster to zero after inactivity; requires `min_capacity = 0`.
  Null creates a provisioned cluster instead.
  EOT
  type = object({
    min_capacity             = number
    max_capacity             = number
    seconds_until_auto_pause = optional(number)
  })
  default = null
}

variable "publicly_accessible" {
  description = "Assign public IPs to the cluster instances. Keep false unless you really need it."
  type        = bool
  default     = false
}

########################################
# Credentials
########################################

variable "master_username" {
  description = "Master username."
  type        = string
  default     = "dbadmin"
}

variable "manage_master_user_password" {
  description = "Let RDS generate and rotate the master password in Secrets Manager (recommended). When true, `master_password` is ignored."
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key used to encrypt the Secrets Manager secret when `manage_master_user_password` is true. Null uses the AWS-managed key."
  type        = string
  default     = null
}

variable "master_password" {
  description = "Master password. Only used when `manage_master_user_password` is false. Prefer the managed option; if you must set this, source it from a secret store and never commit it."
  type        = string
  default     = null
  sensitive   = true
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication."
  type        = bool
  default     = false
}

variable "iam_roles" {
  description = "IAM role ARNs to associate with the cluster, for example to allow S3 import or export."
  type        = list(string)
  default     = []
}

########################################
# Networking
########################################

variable "vpc_id" {
  description = "VPC in which the security group is created. Required unless `vpc_security_group_ids` is set."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group. Ignored when `db_subnet_group_name` is set."
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Name of an existing DB subnet group to use instead of creating one."
  type        = string
  default     = null
}

variable "availability_zones" {
  description = "Availability zones for the cluster. Leave empty to let Aurora choose."
  type        = list(string)
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the cluster port. Only used when the module creates the security group."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach the cluster port. Only used when the module creates the security group."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Existing security groups to attach to the cluster. When set, the module does not create one."
  type        = list(string)
  default     = []
}

########################################
# Storage
########################################

variable "storage_encrypted" {
  description = "Encrypt the cluster storage at rest."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key used for storage encryption. Null uses the AWS-managed `aws/rds` key."
  type        = string
  default     = null
}

variable "storage_type" {
  description = "Aurora storage type: null for the standard configuration, or `aurora-iopt1` for I/O-Optimized."
  type        = string
  default     = null
}

########################################
# Parameter groups
########################################

variable "parameter_group_family" {
  description = "Parameter group family, e.g. `aurora-postgresql16` or `aurora-mysql8.0`. Required when `cluster_parameters` or `instance_parameters` is non-empty."
  type        = string
  default     = null
}

variable "cluster_parameters" {
  description = "Cluster-level parameters set in a module-managed cluster parameter group. Keys are parameter names."
  type = map(object({
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = {}
}

variable "instance_parameters" {
  description = "Instance-level parameters set in a module-managed DB parameter group. Keys are parameter names."
  type = map(object({
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = {}
}

variable "db_cluster_parameter_group_name" {
  description = "Name of an existing cluster parameter group. Takes precedence over `cluster_parameters`."
  type        = string
  default     = null
}

variable "db_parameter_group_name" {
  description = "Name of an existing DB parameter group for the instances. Takes precedence over `instance_parameters`."
  type        = string
  default     = null
}

########################################
# Backups / maintenance / protection
########################################

variable "backup_retention_period" {
  description = "Days to retain automated backups (1 to 35)."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily UTC window for automated backups, e.g. `03:00-04:00`. Must not overlap the maintenance window."
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "Weekly UTC maintenance window, e.g. `Sun:04:30-Sun:05:30`."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Copy cluster tags to snapshots."
  type        = bool
  default     = true
}

variable "backtrack_window" {
  description = "Backtrack window in seconds (Aurora MySQL only). 0 disables backtracking."
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Prevent the cluster from being deleted. Recommended for production."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Set to false for anything you care about."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier_prefix" {
  description = "Prefix for the final snapshot identifier when `skip_final_snapshot` is false."
  type        = string
  default     = "final"
}

variable "snapshot_identifier" {
  description = "Snapshot or cluster snapshot to restore from. Null creates an empty cluster."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of during the next maintenance window."
  type        = bool
  default     = false
}

########################################
# Observability
########################################

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch. Null uses the engine default: `[\"postgresql\"]` for Aurora PostgreSQL, `[\"audit\", \"error\", \"general\", \"slowquery\"]` for Aurora MySQL. Pass `[]` to disable."
  type        = list(string)
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights on the cluster instances."
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention in days: 7 (free), 465, or a multiple of 31."
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "KMS key for Performance Insights data. Null uses the AWS-managed key."
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds: 0 (off), 1, 5, 10, 15, 30 or 60. The module creates the monitoring IAM role when non-zero and `monitoring_role_arn` is null."
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  description = "ARN of an existing Enhanced Monitoring role. Null lets the module create one when `monitoring_interval` is non-zero."
  type        = string
  default     = null
}

########################################
# Advanced
########################################

variable "enable_http_endpoint" {
  description = "Enable the RDS Data API. Supported on Serverless v2 and provisioned Aurora clusters."
  type        = bool
  default     = false
}

variable "global_cluster_identifier" {
  description = "Aurora global cluster to join."
  type        = string
  default     = null
}

variable "replication_source_identifier" {
  description = "ARN of a source cluster or instance to replicate from."
  type        = string
  default     = null
}

variable "source_region" {
  description = "Source region for cross-region encrypted replication."
  type        = string
  default     = null
}
