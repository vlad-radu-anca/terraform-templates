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
  for_each = { for r in var.cloudwatch_event_rule : r.name => r }

  name                = each.value.name
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
  event_bus_name      = each.value.event_bus_name
  event_pattern       = each.value.event_pattern
  role_arn            = each.value.role_arn

  # "state" replaces the deprecated "is_enabled" argument.
  state = each.value.state

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${each.value.name}-event"
  }
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for t in var.cloudwatch_event_target : coalesce(t.target_id, "${t.rule}-target") => t }

  rule           = each.value.rule
  event_bus_name = each.value.event_bus_name
  target_id      = each.value.target_id
  arn            = each.value.arn
  input          = each.value.input
  input_path     = each.value.input_path
  role_arn       = each.value.role_arn
}
