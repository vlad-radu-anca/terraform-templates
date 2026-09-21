variable "db_subnet_group_name" {
  description = "The name of the docDB subnet group. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "description" {
  description = "The description of the docDB subnet group."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs."
  type        = list(string)
  default     = null
}

variable "docdb_instance_apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default isfalse."
  type        = bool
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true."
  type        = bool
  default     = null
}

variable "availability_zone" {
  description = "The EC2 Availability Zone that the DB instance is created in. See docs about the details."
  type        = string
  default     = null
}

variable "availability_zones" {
  description = "The EC2 Availability Zone that the DB instance is created in. See docs about the details."
  type        = list(string)
  default     = null
}

variable "cluster_identifier" {
  description = "The identifier of the aws_docdb_cluster in which to launch this instance."
  type        = string
  default     = null
}

variable "docdb_instance_engine" {
  description = "The name of the database engine to be used for the DocDB instance. Defaults to docdb. Valid Values: docdb."
  type        = string
  default     = null
}

variable "instance_indetifier" {
  description = "The identifier for the DocDB instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance class to use. For details on CPU and memory, see Scaling for DocDB Instances."
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'."
  type        = string
  default     = null
}

variable "promotion_tier" {
  description = "Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer."
  type        = number
  default     = null
}


variable "docdb_cluster_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false."
  type        = bool
  default     = null
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default 1"
  type        = number
  default     = null
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "A value that indicates whether the DB cluster has deletion protection enabled."
  type        = bool
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, profiler."
  type        = list(string)
  default     = null
}

variable "docdb_cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster. Defaults to docdb. Valid Values: docdb"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage."
  type        = string
  default     = null
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true."
  type        = string
  default     = null
}

variable "master_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocDB Naming Constraints."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Username for the master DB user."
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  type        = string
  default     = null
}

variable "snapshot_identifier" {
  description = " Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  type        = bool
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted. The default is false."
  type        = bool
  default     = null
}

variable "vpc_security_group_ids" {
  description = " List of VPC security groups to associate with the Cluster"
  type        = list(string)
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
