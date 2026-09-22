variable "cloudwatch_log_group_name" {
  description = "Names of the CloudWatch log groups to create."
  type        = list(string)
  default     = []
}

variable "cloudwatch_kms_key_id" {
  description = "ARN of the KMS key used to encrypt log data. Null uses CloudWatch default encryption."
  type        = string
  default     = null
}

variable "logs_retention_days" {
  description = "Log retention in days. One of 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, or 0 to retain forever."
  type        = number
  default     = 30
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

variable "cloudwatch_event_rule" {
  description = <<-EOT
  EventBridge rules, keyed internally by `name`. Set either `schedule_expression` for a
  scheduled rule or `event_pattern` for an event-driven one. `state` replaces the
  deprecated `is_enabled` argument: use `ENABLED`, `DISABLED`, or
  `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`.
  EOT
  type = list(object({
    name                = string
    description         = optional(string)
    schedule_expression = optional(string)
    event_bus_name      = optional(string)
    event_pattern       = optional(string)
    role_arn            = optional(string)
    state               = optional(string, "ENABLED")
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.cloudwatch_event_rule :
      contains(["ENABLED", "DISABLED", "ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS"], r.state)
    ])
    error_message = "state must be ENABLED, DISABLED or ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS."
  }
}

variable "cloudwatch_event_target" {
  description = "Targets invoked by the rules above. `target_id` defaults to `<rule>-target` when omitted, and is used as the map key."
  type = list(object({
    rule           = string
    arn            = string
    target_id      = optional(string)
    event_bus_name = optional(string)
    input          = optional(string)
    input_path     = optional(string)
    role_arn       = optional(string)
  }))
  default = []
}
