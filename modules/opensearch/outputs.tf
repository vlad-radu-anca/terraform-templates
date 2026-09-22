output "domain_id" {
  description = "Unique identifier of the domain."
  value       = aws_opensearch_domain.this.domain_id
}

output "domain_name" {
  description = "Name of the domain."
  value       = aws_opensearch_domain.this.domain_name
}

output "arn" {
  description = "ARN of the domain."
  value       = aws_opensearch_domain.this.arn
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search and data upload requests."
  value       = aws_opensearch_domain.this.endpoint
}

output "dashboard_endpoint" {
  description = "Endpoint for OpenSearch Dashboards."
  value       = aws_opensearch_domain.this.dashboard_endpoint
}

output "engine_version" {
  description = "Engine version running on the domain."
  value       = aws_opensearch_domain.this.engine_version
}

output "security_group_id" {
  description = "ID of the security group created for the domain, or null when the domain is public or existing groups were supplied."
  value       = try(aws_security_group.this[0].id, null)
}

output "log_group_arns" {
  description = "ARNs of the module-created CloudWatch log groups, keyed by log type."
  value       = { for t, lg in aws_cloudwatch_log_group.this : t => lg.arn }
}
