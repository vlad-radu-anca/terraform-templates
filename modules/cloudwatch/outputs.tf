output "log_group_arns" {
  description = "ARNs of the created log groups, keyed by log group name."
  value       = { for name, lg in aws_cloudwatch_log_group.cloudwatch_log_group : name => lg.arn }
}

output "log_group_names" {
  description = "Names of the created log groups, keyed by log group name."
  value       = { for name, lg in aws_cloudwatch_log_group.cloudwatch_log_group : name => lg.name }
}

output "event_rule_arns" {
  description = "ARNs of the EventBridge rules, keyed by rule name."
  value       = { for name, r in aws_cloudwatch_event_rule.this : name => r.arn }
}

output "event_rule_ids" {
  description = "IDs of the EventBridge rules, keyed by rule name."
  value       = { for name, r in aws_cloudwatch_event_rule.this : name => r.id }
}

output "event_target_ids" {
  description = "IDs of the EventBridge targets, keyed by target ID."
  value       = { for id, t in aws_cloudwatch_event_target.this : id => t.target_id }
}
