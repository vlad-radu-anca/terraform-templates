variable "domain_name" {
}

variable "access_policies" {
  description               = "IAM policy document specifying the access policies for the domain"
  type                      = string
  default                   = null
}

variable "ebs_options" {
}

variable "cluster_config" {
  description               = "Cluster configuration of the domain"
  default  = []
}

variable "vpc_options" {
}

variable "elasticsearch_version" {
  description               = "The version of Elasticsearch to deploy. Defaults to 1.5"
  type                      = string
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
