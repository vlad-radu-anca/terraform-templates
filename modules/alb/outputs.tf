
output "load_balancer_arn" {
  description = "ARN of the load balancer."
  value       = aws_lb.this[0].arn
}

output "target_group_arn" {
  description = "Map of target group name to target group ID."
  value       = zipmap(aws_lb_target_group.this[*].name, aws_lb_target_group.this[*].id)
}
