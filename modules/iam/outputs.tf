output "iam_role_arn" {
  value = zipmap(aws_iam_role.this[*].name, aws_iam_role.this[*].arn)
}

output "iam_role_id" {
  value = zipmap(aws_iam_role.this[*].name, aws_iam_role.this[*].id)
}
