output "id" {
  description = "Bucket name."
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "Bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Global domain name of the bucket."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the bucket. Use this as a CloudFront origin."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID for the bucket's region, for alias records."
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "region" {
  description = "Region the bucket was created in."
  value       = aws_s3_bucket.this.region
}

output "website_endpoint" {
  description = "Static website endpoint, if a website configuration was created."
  value       = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}

output "website_domain" {
  description = "Domain of the static website endpoint, for Route 53 aliases."
  value       = try(aws_s3_bucket_website_configuration.this[0].website_domain, null)
}
