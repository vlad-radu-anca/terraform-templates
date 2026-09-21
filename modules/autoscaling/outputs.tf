output "autoscaling_policy_name" {
  value = values(aws_appautoscaling_policy.autoscaling_policy)[*].name
}