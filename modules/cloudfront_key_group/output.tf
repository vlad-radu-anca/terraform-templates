output "cloudfront_key_id" {
  value = values(aws_cloudfront_public_key.cloudfront_public_key)[*].id
}

output "cloudfront_key_group_id" {
  value = aws_cloudfront_key_group.keygroup.id
}