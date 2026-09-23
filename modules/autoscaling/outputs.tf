output "autoscaling_policy_name" {
  description = "Names of the scaling policies created."
  value       = values(aws_appautoscaling_policy.autoscaling_policy)[*].name
}

output "autoscaling_policy_arns" {
  description = "ARNs of the scaling policies, keyed by policy name."
  value       = { for k, p in aws_appautoscaling_policy.autoscaling_policy : k => p.arn }
}

output "scalable_target_resource_id" {
  description = "Resource ID of the registered scalable target."
  value       = aws_appautoscaling_target.autoscalling_target.resource_id
}
