output "cloudfront_key_id" {
  description = "IDs of the CloudFront public keys created."
  value       = values(aws_cloudfront_public_key.cloudfront_public_key)[*].id
}

output "cloudfront_key_group_id" {
  description = "ID of the key group, for use in a cache behavior's `trusted_key_groups`."
  value       = aws_cloudfront_key_group.keygroup.id
}
