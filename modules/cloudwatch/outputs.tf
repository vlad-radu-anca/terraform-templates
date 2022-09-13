output "cloudwatch_logging_arn" {
  value = {for cloudwatch_log_group_name in var.cloudwatch_log_group_name: cloudwatch_log_group_name=>aws_cloudwatch_log_group.cloudwatch_log_group[cloudwatch_log_group_name].arn}
}

output "cloudwatch_event_rule_id" {
  value = zipmap(aws_cloudwatch_event_rule.this[*].id, aws_cloudwatch_event_rule.this[*].id)
}

output "cloudwatch_event_rule_arn" {
  value = zipmap(aws_cloudwatch_event_rule.this[*].id, aws_cloudwatch_event_rule.this[*].arn)
}

