resource "aws_appautoscaling_target" "autoscalling_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = var.resource_id
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
}

resource "aws_appautoscaling_policy" "autoscaling_policy" {

  for_each           = var.autoscaling_policy_vars
  name               = each.key
  policy_type        = each.value.policy_type
  resource_id        = aws_appautoscaling_target.autoscalling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.autoscalling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscalling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.predefined_metric_type
    }
    target_value = each.value.target_value
  }
}
