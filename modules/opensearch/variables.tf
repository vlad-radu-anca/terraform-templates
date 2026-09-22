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

variable "domain_name" {
  description = "OpenSearch domain name. Defaults to `<project_name>-<environment>`. Must be lowercase and start with a letter."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}

########################################
# Engine and cluster
########################################

variable "engine_version" {
  description = "Engine version, for example `OpenSearch_2.17` or `Elasticsearch_7.10`. Null lets AWS pick its current default, so pin this for production."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Data node instance type, for example `t3.small.search` or `r6g.large.search`."
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of data nodes. Use a multiple of the availability zone count when zone awareness is on."
  type        = number
  default     = 2
}

variable "dedicated_master" {
  description = "Dedicated master nodes, which AWS recommends for production domains. `count` should be 3 or 5."
  type = object({
    enabled       = optional(bool, false)
    instance_type = optional(string, "t3.small.search")
    count         = optional(number, 3)
  })
  default = {}
}

variable "warm_storage" {
  description = "UltraWarm nodes for older, less frequently queried indices."
  type = object({
    enabled       = optional(bool, false)
    instance_type = optional(string, "ultrawarm1.medium.search")
    count         = optional(number, 2)
  })
  default = {}
}

variable "multi_az_with_standby_enabled" {
  description = "Enable Multi-AZ with standby, which requires three availability zones and three dedicated master nodes."
  type        = bool
  default     = false
}

variable "ebs" {
  description = "EBS storage for the data nodes. `iops` and `throughput` only apply to `gp3`."
  type = object({
    enabled     = optional(bool, true)
    volume_size = optional(number, 20)
    volume_type = optional(string, "gp3")
    iops        = optional(number)
    throughput  = optional(number)
  })
  default = {}
}

########################################
# Networking
########################################

variable "vpc_id" {
  description = "VPC in which the security group is created. Required when `subnet_ids` is set and `security_group_ids` is empty."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the domain ENIs. Leave empty for a public domain, which then relies entirely on `access_policies`."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Existing security groups to attach. When set, the module does not create one."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the domain on port 443. Only used when the module creates the security group."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to reach the domain on port 443. Only used when the module creates the security group."
  type        = list(string)
  default     = []
}

variable "ip_address_type" {
  description = "IP address type: `ipv4` or `dualstack`."
  type        = string
  default     = null
}

variable "custom_endpoint" {
  description = "Serve the domain on a custom domain name. The certificate must be an ACM certificate in the same region."
  type = object({
    name            = string
    certificate_arn = string
  })
  default = null
}

########################################
# Security
########################################

variable "encrypt_at_rest" {
  description = "Encrypt data at rest."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key for encryption at rest. Null uses the AWS-managed OpenSearch key."
  type        = string
  default     = null
}

variable "node_to_node_encryption" {
  description = "Encrypt traffic between nodes."
  type        = bool
  default     = true
}

variable "enforce_https" {
  description = "Require HTTPS on the domain endpoint."
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "Minimum TLS policy for the endpoint."
  type        = string
  default     = "Policy-Min-TLS-1-2-PFS-2023-10"
}

variable "fine_grained_access_control" {
  description = <<-EOT
  Fine-grained access control. Set `master_user_arn` to use an IAM principal as master (recommended),
  or `master_user_name` and `master_user_password` to use the internal user database.
  Fine-grained access control requires encryption at rest, node-to-node encryption and HTTPS.
  Null disables it.
  EOT
  type = object({
    master_user_arn        = optional(string)
    master_user_name       = optional(string)
    master_user_password   = optional(string)
    anonymous_auth_enabled = optional(bool, false)
  })
  default   = null
  sensitive = true
}

variable "access_policies" {
  description = "Domain access policy as a JSON string. Required for a public domain, optional for a VPC domain."
  type        = string
  default     = null
}

variable "advanced_options" {
  description = "Advanced options passed to the domain, for example `{ \"rest.action.multi.allow_explicit_index\" = \"true\" }`."
  type        = map(string)
  default     = {}
}

########################################
# Logging
########################################

variable "published_log_types" {
  description = "Log types to publish. Valid values: `INDEX_SLOW_LOGS`, `SEARCH_SLOW_LOGS`, `ES_APPLICATION_LOGS`, `AUDIT_LOGS`. Auditing requires fine-grained access control."
  type        = list(string)
  default     = ["ES_APPLICATION_LOGS", "INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS"]

  validation {
    condition = alltrue([
      for t in var.published_log_types :
      contains(["INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS", "ES_APPLICATION_LOGS", "AUDIT_LOGS"], t)
    ])
    error_message = "published_log_types entries must be INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS or AUDIT_LOGS."
  }
}

variable "create_log_groups" {
  description = "Create a CloudWatch log group per published log type, along with the resource policy the service needs to write to them."
  type        = bool
  default     = true
}

variable "existing_log_group_arns" {
  description = "Log group ARNs keyed by log type, used when `create_log_groups` is false."
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Retention for the module-created log groups."
  type        = number
  default     = 30
}

variable "log_kms_key_id" {
  description = "KMS key for the module-created log groups. Null uses CloudWatch default encryption."
  type        = string
  default     = null
}

########################################
# Maintenance
########################################

variable "auto_tune_enabled" {
  description = "Enable Auto-Tune, which adjusts JVM and queue settings based on observed workload."
  type        = bool
  default     = true
}

variable "off_peak_window_enabled" {
  description = "Enable the daily off-peak window used for service software updates and Auto-Tune changes."
  type        = bool
  default     = true
}

variable "off_peak_window_start_hour" {
  description = "Hour (UTC, 0 to 23) at which the off-peak window starts. Null lets AWS choose."
  type        = number
  default     = null
}

variable "auto_software_update_enabled" {
  description = "Apply service software updates automatically during the off-peak window."
  type        = bool
  default     = true
}

variable "automated_snapshot_start_hour" {
  description = "Hour (UTC, 0 to 23) for automated snapshots. Only applies to Elasticsearch 5.3 and earlier; newer domains snapshot hourly."
  type        = number
  default     = null
}
