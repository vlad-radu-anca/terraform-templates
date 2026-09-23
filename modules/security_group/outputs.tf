output "security_group_ids" {
  description = "Map of security group name to security group ID."
  value       = zipmap(aws_security_group.this[*].name, aws_security_group.this[*].id)
}

output "security_group_arns" {
  description = "ARNs of the security groups created."
  value       = aws_security_group.this[*].arn
}
