output "ssm_parameter_name" {
  description = "Map of parameter name to parameter ARN."
  value       = zipmap(aws_ssm_parameter.this[*].name, aws_ssm_parameter.this[*].arn)
}

output "ssm_parameter_arns" {
  description = "ARNs of the parameters created."
  value       = aws_ssm_parameter.this[*].arn
}

output "ssm_parameter_versions" {
  description = "Map of parameter name to its current version number."
  value       = zipmap(aws_ssm_parameter.this[*].name, aws_ssm_parameter.this[*].version)
}
