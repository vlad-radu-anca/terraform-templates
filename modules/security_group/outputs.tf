
output "security_group_ids" {
    value = zipmap(aws_security_group.this[*].name, aws_security_group.this[*].id)
}
