variable "cloudwatch_log_group_name" {
  default = []
}

variable "cloudwatch_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data"
  default = null
}

variable "logs_retention_days" {
  description = "Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653"
  default = "30"
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

variable "cloudwatch_event_rule" {
  description = "description"
  type         = list(object({
    name = string
    schedule_expression = string
    event_bus_name = string
    event_pattern = string
    description = string
    role_arn = string
    is_enabled = bool
  }))
  default     = []
}

variable "cloudwatch_event_target" {
  description = "description"
  type         = list(object({
    rule = string
    event_bus_name = string
    target_id = string
    arn = string
    input = string
    input_path = string
    role_arn = string
  }))
  default     = []
}

