/*variable "domain_name" {
  description               = "Name of the domain."
  type                      = list(string)
  default                   = []
}

variable "access_policies" {
  description               = "IAM policy document specifying the access policies for the domain"
  type                      = string
  default                   = null
}

variable "advanced_security_options" {
  description               = "Options for fine-grained access control."
  type                      = list(object({
    enabled = bool
    internal_user_database_enabled = bool
    master_user_options = list(object({
        master_user_arn = string
        master_user_name = string
        master_user_password = string
        }))
    }))
  default                   = []
}

variable "ebs_options" {
  description               = "EBS related options, may be required based on chosen instance size."
  type                      = list(object({
    ebs_enabled = bool
    volume_size = number
    volume_type = string
    iops = number
  }))
  default                   =  []
}

variable "encrypt_at_rest" {
  description               = "Encrypt at rest options. Only available for certain instance types."
  type                      = list(object({
    enabled = bool
    kms_key_id = string
  }))
  default                   = []
}

variable "node_to_node_encryption_enabled" {
  description               = "Node-to-node encryption"
  type                      = bool
  default                   = null
}

variable "cluster_config" {
  description               = "Cluster configuration of the domain"
  type                      = list(object({
    instance_type = string
    instance_count = number
    dedicated_master_enabled = number
    dedicated_master_type = string
    dedicated_master_count = number
    zone_awareness_config = list(object({
      availability_zone_count = number
    }))
    zone_awareness_enabled = bool
    warm_enabled = bool
    warm_count = number
    warm_type = string
  }))
  default  = []
}

variable "snapshot_options" {
  description               = "Snapshot related options"
  type                      = list(object({
    automated_snapshot_start_hour = number
  }))
  default                   = []
}

variable "vpc_options" {
  description               = "VPC related options, see below. Adding or removing this configuration forces a new resource"
  type                      = list(object({
    security_group_ids = list(string)
    subnet_ids = list(string) 
  }))
  default                   = []
}

variable "log_publishing_options" {
  description               = "Options for publishing slow and application logs to CloudWatch Logs. This block can be declared multiple times, for each log_type, within the same resource."
  type                      = list(object({
    log_type = string
    cloudwatch_log_group_arn = string
    enabled = bool
  }))
  default                   = []
}

variable "cognito_options" {
  description               = "Options for authenticating Kibana with Cognito."
  type                      = list(object({
    enabled = bool
    user_pool_id = string
    identity_pool_id = string
    role_arn = string
  }))
  default                   = []
}

variable "elasticsearch_version" {
  description               = "The version of Elasticsearch to deploy. Defaults to 1.5"
  type                      = string
  default                   = null
}

variable "domain_endpoint_options" {
  description               = "Domain endpoint HTTP(S) related options."
  type                      = list(object({
    enforce_https = bool
    tls_security_policy = string
  }))
  default                   = []
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
*/