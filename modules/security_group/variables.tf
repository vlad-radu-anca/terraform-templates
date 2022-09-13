variable "security_group" {
  description = "description"
  type         = list(object({
    name = string
    revoke_rules_on_delete = bool
    vpc_id = string
    sg_rules_ingress = list(object({
      cidr_blocks = list(string)
      from_port = number
      protocol = string
      security_groups = list(string)
      self        = bool
      to_port = number
      description = string
    }))
    sg_rules_egress = list(object({
      cidr_blocks = list(string)
      from_port = number
      protocol = string
      security_groups = list(string)
      self        = bool
      to_port = number
      description = string
    }))
  }))
  default     = []
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
