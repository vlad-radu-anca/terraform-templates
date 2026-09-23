variable "ssm_parameter" {
  description = <<-EOT
  SSM parameters to create. `type` is `String`, `StringList` or `SecureString`; `SecureString`
  is encrypted with `key_id`, or the account's default SSM key when that is null.
  `tier` is `Standard`, `Advanced` or `Intelligent-Tiering`.
  EOT
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