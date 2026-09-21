
output "ssm_parameter_name" {
  value = zipmap(aws_ssm_parameter.this[*].name, aws_ssm_parameter.this[*].arn)
}
