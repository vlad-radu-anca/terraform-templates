output "kms_id" {
  description = "Globally unique identifier of the key."
  value       = aws_kms_key.this.id
}

output "kms_arn" {
  description = "ARN of the key, used wherever a `kms_key_id` or `kms_key_arn` is expected."
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "Key ID, the portion of the ARN after `key/`."
  value       = aws_kms_key.this.key_id
}

output "alias_name" {
  description = "Name of the alias pointing at the key."
  value       = aws_kms_alias.this.name
}

output "alias_arn" {
  description = "ARN of the alias."
  value       = aws_kms_alias.this.arn
}
