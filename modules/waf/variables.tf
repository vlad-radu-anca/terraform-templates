variable "description" {
  type = string
  description = "A friendly description of the WebACL."
  default = null
}

variable "name" {
  type = string
  description = "A friendly name of the WebACL."
  default = null
}

variable "scope" {
  type = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL"
  default = null
}

variable "cloudwatch_metrics_enabled" {
  type = bool
  description = "A boolean indicating whether the associated resource sends metrics to CloudWatch."
  default = null
}

variable "metric_name" {
  type = string
  description = "A friendly name of the CloudWatch metric. The name can contain only alphanumeric characters (A-Z, a-z, 0-9) hyphen(-) and underscore (_), with length from one to 128 characters. It can't contain whitespace or metric names reserved for AWS WAF, for example All and Default_Action"
  default = null
}

variable "sampled_requests_enabled" {
  type = bool
  description = "A boolean indicating whether AWS WAF should store a sampling of the web requests that match the rules. You can view the sampled requests through the AWS WAF console."
  default = null
}

variable "resource_arn" {
  type = string
  description = "The Amazon Resource Name (ARN) of the Web ACL that you want to associate with the resource."
  default = null
}

variable "environment" {
  type = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default = "testing"
}

variable "project_name" {
  type = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default = "makeen-infra-templates"
}