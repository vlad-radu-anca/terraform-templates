variable "max_capacity" {
  description = "Maximum capacity the target can scale out to."
  type        = number
}

variable "min_capacity" {
  description = "Minimum capacity the target can scale in to."
  type        = number
}

variable "resource_id" {
  description = "Identifier of the resource to scale, for example `service/my-cluster/my-service` for an ECS service."
  type        = string
}

variable "scalable_dimension" {
  description = "Dimension of the scalable target, for example `ecs:service:DesiredCount`."
  type        = string
}

variable "service_namespace" {
  description = "AWS service namespace of the scalable target, for example `ecs`, `dynamodb` or `rds`."
  type        = string
}

variable "autoscaling_policy_vars" {
  description = <<-EOT
  Target tracking scaling policies keyed by policy name. `predefined_metric_type` is a metric such as
  `ECSServiceAverageCPUUtilization` or `ALBRequestCountPerTarget`, and `target_value` is the value
  Application Auto Scaling keeps the metric near.
  EOT
  type = map(object({
    policy_type            = optional(string, "TargetTrackingScaling")
    predefined_metric_type = string
    target_value           = number
  }))
  default = {}
}
