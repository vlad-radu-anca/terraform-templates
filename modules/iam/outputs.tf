output "iam_role_arn" {
  description = "Map of IAM role name to role ARN."
  value       = zipmap(aws_iam_role.this[*].name, aws_iam_role.this[*].arn)
}

output "iam_role_id" {
  description = "Map of IAM role name to role ID, which is what `aws_iam_role_policy` expects as `role_id`."
  value       = zipmap(aws_iam_role.this[*].name, aws_iam_role.this[*].id)
}
