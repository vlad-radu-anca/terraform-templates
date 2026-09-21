resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  for_each          = toset(var.cloudwatch_log_group_name)
  name              = each.value
  retention_in_days = var.logs_retention_days
  kms_key_id        = var.cloudwatch_kms_key_id == null ? null : var.cloudwatch_kms_key_id

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${each.value}"
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  count               = length(var.cloudwatch_event_rule)
  name                = lookup(var.cloudwatch_event_rule[count.index], "name", null)
  schedule_expression = lookup(var.cloudwatch_event_rule[count.index], "schedule_expression", null)
  event_bus_name      = lookup(var.cloudwatch_event_rule[count.index], "event_bus_name", null)
  event_pattern       = lookup(var.cloudwatch_event_rule[count.index], "event_pattern", null)
  description         = lookup(var.cloudwatch_event_rule[count.index], "description", null)
  role_arn            = lookup(var.cloudwatch_event_rule[count.index], "role_arn", null)
  is_enabled          = lookup(var.cloudwatch_event_rule[count.index], "is_enabled", null)
  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${lookup(var.cloudwatch_event_rule[count.index], "name", null)}-event"
  }
}

resource "aws_cloudwatch_event_target" "this" {
  count          = length(var.cloudwatch_event_target)
  rule           = lookup(var.cloudwatch_event_target[count.index], "rule", null)
  event_bus_name = lookup(var.cloudwatch_event_target[count.index], "event_bus_name", null)
  target_id      = lookup(var.cloudwatch_event_target[count.index], "target_id", null)
  arn            = lookup(var.cloudwatch_event_target[count.index], "arn", null)
  input          = lookup(var.cloudwatch_event_target[count.index], "input", null)
  input_path     = lookup(var.cloudwatch_event_target[count.index], "input_path", null)
  role_arn       = lookup(var.cloudwatch_event_target[count.index], "role_arn", null)
}
