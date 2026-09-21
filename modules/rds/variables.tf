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

variable "identifier" {
  description = "DB instance identifier. Defaults to `<project_name>-<environment>-<engine>`."
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
  description = "Database engine. One of `postgres`, `mysql`, `mariadb`."
  type        = string

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.engine)
    error_message = "engine must be one of: postgres, mysql, mariadb."
  }
}

variable "engine_version" {
  description = "Engine version, e.g. `16.4` for PostgreSQL or `8.0.39` for MySQL. Leave null to let AWS pick the default for the engine."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Instance class, e.g. `db.t4g.medium`."
  type        = string
  default     = "db.t4g.medium"
}

variable "port" {
  description = "Port the database listens on. Defaults to the engine's standard port (5432 for postgres, 3306 for mysql/mariadb)."
  type        = number
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Apply minor engine upgrades automatically during the maintenance window."
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major engine version upgrades when `engine_version` changes."
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "Identifier of the CA certificate for the instance, e.g. `rds-ca-rsa2048-g1`. Null keeps the RDS default."
  type        = string
  default     = null
}

########################################
# Storage
########################################

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit in GiB for storage autoscaling. Set to 0 to disable autoscaling."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type: `gp3` (recommended), `gp2`, or `io1`/`io2`."
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "Provisioned IOPS. Only meaningful for `io1`/`io2`, or `gp3` above 400 GiB."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput in MiB/s. Only valid for `gp3` above 400 GiB."
  type        = number
  default     = null
}

variable "storage_encrypted" {
  description = "Encrypt the storage at rest."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key used for storage encryption. Null uses the AWS-managed `aws/rds` key."
  type        = string
  default     = null
}

########################################
# Credentials / database
########################################

variable "db_name" {
  description = "Name of the initial database to create. Null skips creation (MySQL/MariaDB) or creates `postgres` (PostgreSQL)."
  type        = string
  default     = null
}

variable "username" {
  description = "Master username."
  type        = string
  default     = "dbadmin"
}

variable "manage_master_user_password" {
  description = "Let RDS generate and rotate the master password in Secrets Manager (recommended). When true, `password` is ignored."
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "KMS key used to encrypt the Secrets Manager secret when `manage_master_user_password` is true. Null uses the AWS-managed key."
  type        = string
  default     = null
}

variable "password" {
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

########################################
# Networking
########################################

variable "vpc_id" {
  description = "VPC in which the security group is created."
  type        = string
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

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the database port."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach the database port."
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Extra security groups to attach to the instance, in addition to the one created by this module."
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Assign a public IP to the instance. Keep false unless you really need it."
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Deploy a standby replica in another AZ for high availability."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "AZ for a single-AZ instance. Ignored when `multi_az` is true."
  type        = string
  default     = null
}

variable "network_type" {
  description = "Network type: `IPV4` or `DUAL`."
  type        = string
  default     = "IPV4"
}

########################################
# Parameter / option groups
########################################

variable "parameter_group_family" {
  description = "Parameter group family, e.g. `postgres16` or `mysql8.0`. Required when `parameters` is non-empty."
  type        = string
  default     = null
}

variable "parameters" {
  description = "Engine parameters to set in a module-managed parameter group. Keys are parameter names."
  type = map(object({
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = {}
}

variable "parameter_group_name" {
  description = "Name of an existing parameter group to use instead of creating one. Takes precedence over `parameters`."
  type        = string
  default     = null
}

variable "option_group_engine_version" {
  description = "Major engine version for a module-managed option group (MySQL/MariaDB only), e.g. `8.0`. Required when `options` is non-empty."
  type        = string
  default     = null
}

variable "options" {
  description = "Options to set in a module-managed option group (MySQL/MariaDB only). Keys are option names."
  type = map(object({
    port                           = optional(number)
    version                        = optional(string)
    db_security_group_memberships  = optional(list(string), [])
    vpc_security_group_memberships = optional(list(string), [])
    settings                       = optional(map(string), {})
  }))
  default = {}
}

variable "option_group_name" {
  description = "Name of an existing option group to use instead of creating one. Takes precedence over `options`."
  type        = string
  default     = null
}

########################################
# Backups / maintenance / protection
########################################

variable "backup_retention_period" {
  description = "Days to retain automated backups (0 disables; 1 or more is required for read replicas)."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily UTC window for automated backups, e.g. `03:00-04:00`. Must not overlap `maintenance_window`."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Weekly UTC maintenance window, e.g. `Sun:04:30-Sun:05:30`."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Copy instance tags to snapshots."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Prevent the instance from being deleted. Recommended for production."
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

variable "apply_immediately" {
  description = "Apply modifications immediately instead of during the next maintenance window."
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "Snapshot to restore the instance from. Null creates an empty instance."
  type        = string
  default     = null
}

########################################
# Observability
########################################

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
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
  description = "Enhanced Monitoring interval in seconds: 0 (off), 1, 5, 10, 15, 30 or 60. The module creates the monitoring IAM role when non-zero."
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be one of 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch. Null uses the engine default: `[\"postgresql\", \"upgrade\"]` for postgres, `[\"error\", \"general\", \"slowquery\"]` for mysql/mariadb. Pass `[]` to disable."
  type        = list(string)
  default     = null
}

########################################
# Read replicas
########################################

variable "replica_count" {
  description = "Number of read replicas to create from the primary instance."
  type        = number
  default     = 0
}

variable "replica_instance_class" {
  description = "Instance class for read replicas. Null uses `instance_class`."
  type        = string
  default     = null
}

variable "replica_multi_az" {
  description = "Deploy read replicas as Multi-AZ."
  type        = bool
  default     = false
}
