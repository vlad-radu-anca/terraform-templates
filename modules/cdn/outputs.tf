output "id" {
  description = "Identifier of the distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "arn" {
  description = "ARN of the distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "Domain name of the distribution, for example `d111111abcdef8.cloudfront.net`."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID for the distribution, used in alias records."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "status" {
  description = "Current status of the distribution."
  value       = aws_cloudfront_distribution.this.status
}

output "etag" {
  description = "Current version of the distribution's information."
  value       = aws_cloudfront_distribution.this.etag
}

output "origin_access_control_ids" {
  description = "Origin access control IDs, keyed by origin ID. Reference these in the S3 bucket policy condition."
  value       = { for k, oac in aws_cloudfront_origin_access_control.this : k => oac.id }
}
