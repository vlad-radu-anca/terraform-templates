variable "iam_role" {
  description = "Name for IAM Roles and Policies,  names of  both are same as provided in list"
  type = list(object({
    name = string
    assume_role_policy = string
  }))
  default = []
}

variable "iam_role_policy" {
  description = "Name for IAM Roles and Policies,  names of  both are same as provided in list"
  type = list(object({
    name = string
    role_id = string
    policy = string
  }))
  default = []
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
