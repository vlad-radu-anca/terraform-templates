variable "vpc_cidr_block" {
  description = "Specify CIDR Range for VPC Network"
  type        = string
  default     = null
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = null
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "nacl_rules" {
  description = "Network ACL Rules"
  type = list(object({
    protocol  = string
    rule_no   = number
    action    = string
    from_port = number
    to_port   = number
  }))
  default = []
}

variable "newbits" {
  description = "The number of additional subnets bits with which to extend the prefix"
  type        = number
  default     = 8
}

variable "multiple_nats" {
  description = "Want Nats per AZ"
  type        = bool
  default     = false
}

variable "public_route_rules" {
  description = "Public Route Table Rules"
  type = list(object({
    cidr_block                = string
    gateway_id                = string
    vpc_peering_connection_id = string
  }))
  default = null
}

variable "private_route_rules" {
  description = "Private Route Table Rules"
  type = list(object({
    cidr_block                = string
    gateway_id                = string
    vpc_peering_connection_id = string
  }))
  default = null
}

variable "create_flow_logs" {
  description = "Want to create Flow Logs"
  type        = bool
  default     = false
}

variable "traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group"
  type        = string
  default     = null
}

variable "log_destination_type" {
  description = "The type of the logging destination. Valid values: cloud-watch-logs, s3."
  type        = string
  default     = "cloud-watch-logs"
}

variable "log_destination" {
  description = "The ARN of the logging destination."
  type        = string
  default     = null
}

variable "max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record."
  type        = number
  default     = 60
}

variable "flow_log_type" {
  description = "Flow logs need to enabled for what? Valid values::VPC,Subnet,ENI"
  type        = string
  default     = "VPC"
}

variable "eni_id" {
  description = "If Flow Log Type is ENI, please specify particular ENI ID"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "If Flow Log Type is Subnet, please specify particular Subnet ID"
  type        = string
  default     = null
}

#Specify either default Cloudfront SSL or Custom ACM SSL

#Specify S3 origin or Cusomt origin

#Multiple Origin Groups with Failover mechanism using "member" parameter

#Custom Error Page and Responses you want Cloudfront to redirect

# Default Cache, can be Maximum one,

#Multiple Ordered Cache Behavior
#Want to enable Geo Restriction in Cloudfront

#controls how logs are written to your distribution

#Want Restricting Access to Amazon S3 Content by Using an Origin Access Identity, so only Cloudfront can access it
#Configure your S3 bucket permissions so that CloudFront can use the OAI to access the files in your bucket and serve them to your users.
#Make sure that users can’t use a direct URL to the S3 bucket to access a file there.

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
