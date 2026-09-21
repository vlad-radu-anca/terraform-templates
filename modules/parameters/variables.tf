variable "ssm_parameter" {
  description = "description"
  type = list(object({
    name            = string
    type            = string
    value           = string
    description     = string
    tier            = string
    key_id          = string
    overwrite       = bool
    allowed_pattern = string
    data_type       = string
  }))
  default = []
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