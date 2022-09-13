variable "elasticache_subnet_group_name" {
  description               = "Group identifier. ElastiCache converts this name to lowercase"
  type                      = string
  default                   = null
}

variable "description" {
  description               = "Group identifier. ElastiCache converts this name to lowercase"
  type                      = string
  default                   = null
}

variable "subnet_ids" {
  description               = "Group identifier. ElastiCache converts this name to lowercase"
  type                      = list(string)
  default                   = null
}

variable "cluster_id" {
  description               = "Group identifier. ElastiCache converts this name to lowercase"
  type                      = string
  default                   = null
}

variable "replication_group_id" {
  description               = "The ID of the replication group to which this cluster should belong."
  type                      = string
  default                   = null
}

variable "engine" {
  description               = "Name of the cache engine to be used for this cache cluster."
  type                      = string
  default                   = null
}

variable "engine_version" {
  description               = "Version number of the cache engine to be used."
  type                      = string
  default                   = null
}

variable "maintenance_window" {
  description               = "Specifies the weekly time range for when maintenance on the cache cluster is performed."
  type                      = string
  default                   = null
}

variable "node_type" {
  description               = "The compute and memory capacity of the nodes. See Available Cache Node Types for supported node types"
  type                      = string
  default                   = null
}

variable "num_cache_nodes" {
  description               = "The initial number of cache nodes that the cache cluster will have. For Redis, this value must be 1. For Memcache, this value must be between 1 and 20. If this number is reduced on subsequent runs, the highest numbered nodes will be removed."
  type                      = number
  default                   = null
}

variable "parameter_group_name" {
  description               = "(Required unless replication_group_id is provided) Name of the parameter group to associate with this cache cluster"
  type                      = string
  default                   = null
}

variable "port" {
  description               = "The port number on which each of the cache nodes will accept connections."
  type                      = number
  default                   = null
}

variable "subnet_group_name" {
  description               = "Name of the subnet group to be used for the cache cluster."
  type                      = string
  default                   = null
}

variable "security_group_ids" {
  description               = "One or more VPC security groups associated with the cache cluster"
  type                      = list(string)
  default                   = null
}

variable "apply_immediately" {
  description               = "Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is false"
  type                      = bool
  default                   = null
}

variable "snapshot_arns" {
  description               = "A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3."
  type                      = set(string)
  default                   = null
}

variable "snapshot_name" {
  description               = "The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
  type                      = string
  default                   = null
}

variable "snapshot_window" {
  description               = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster."
  type                      = string
  default                   = null
}

variable "snapshot_retention_limit" {
  description               = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
  type                      = number
  default                   = null
}

variable "notification_topic_arn" {
  description               = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to."
  type                      = string
  default                   = null
}

variable "az_mode" {
  description               = "Specifies whether the nodes in this Memcached node group are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region."
  type                      = string
  default                   = null
}

variable "availability_zone" {
  description               = "The Availability Zone for the cache cluster. If you want to create cache nodes in multi-az, use preferred_availability_zones instead. Default: System chosen Availability Zone."
  type                      = string
  default                   = null
}

variable "preferred_availability_zones" {
  description               = "A list of the Availability Zones in which cache nodes are created."
  type                      = list(string)
  default                   = null
}

variable "environment" {
  type = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default = "testing"
}

variable "project_name" {
  type = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default = "asgard-infra-templates"
}
