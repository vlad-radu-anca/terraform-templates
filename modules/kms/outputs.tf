output "kms_id" {
  value = aws_kms_key.this.id
}

output "kms_arn" {
  value = aws_kms_key.this.arn
}
