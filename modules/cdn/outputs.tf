output "cloudfront_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}

output "cloudfront_origin_access_identity_iam_arn" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
}
