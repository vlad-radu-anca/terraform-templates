resource "aws_lb" "this" {
  count                            = var.alb_name != null ? 1 : 0
  name                             = var.alb_name
  internal                         = var.internal
  load_balancer_type               = var.load_balancer_type
  security_groups                  = var.alb_security_groups
  subnets                          = var.alb_subnets
  idle_timeout                     = var.idle_timeout
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "access_logs" {
    for_each = var.access_logs
    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = access_logs.value.enabled
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping
    content {
      subnet_id     = var.subnet_id
      allocation_id = var.allocation_id
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.alb_name}-alb"
  }

}

resource "aws_lb_listener" "this" {
  count             = length(var.lb_listener)
  load_balancer_arn = lookup(var.lb_listener[count.index], "load_balancer_arn", null)
  port              = lookup(var.lb_listener[count.index], "alb_listener_port", null)
  protocol          = lookup(var.lb_listener[count.index], "alb_listener_protocol", null)
  ssl_policy        = lookup(var.lb_listener[count.index], "ssl_policy", null)
  certificate_arn   = lookup(var.lb_listener[count.index], "certificate_arn", null)

  dynamic "default_action" {
    for_each = lookup(var.lb_listener[count.index], "default_action", null)
    content {
      type             = default_action.value.type
      target_group_arn = default_action.value.target_group_arn

      dynamic "forward" {

        for_each = default_action.value.forward
        content {
          dynamic "target_group" {
            for_each = forward.value.target_group
            content {
              arn    = target_group.value.arn
              weight = target_group.value.weight
            }
          }
          dynamic "stickiness" {
            for_each = forward.value.stickiness
            content {
              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration
            }
          }
        }
      }
      dynamic "redirect" {
        for_each = default_action.value.redirect
        content {
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          query       = redirect.value.query
          status_code = redirect.value.status_code
        }
      }

      dynamic "fixed_response" {
        for_each = default_action.value.fixed_response
        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }

}

resource "aws_lb_listener_certificate" "this" {
  count           = length(var.attach_certs_to_alb)
  listener_arn    = lookup(var.attach_certs_to_alb[count.index], "listener_arn", null)
  certificate_arn = lookup(var.attach_certs_to_alb[count.index], "certificate_arn", null)
}


resource "aws_lb_listener_rule" "this" {
  count        = length(var.listener_rule)
  listener_arn = lookup(var.listener_rule[count.index], "listener_arn", null)
  priority     = lookup(var.listener_rule[count.index], "priority", null)
  dynamic "action" {
    for_each = lookup(var.listener_rule[count.index], "action", null)
    content {
      type             = action.value.type
      target_group_arn = action.value.target_group_arn

      dynamic "forward" {
        for_each = action.value.forward
        content {
          dynamic "target_group" {
            for_each = forward.value.target_group
            content {
              arn    = target_group.value.arn
              weight = target_group.value.weight
            }
          }
          dynamic "stickiness" {
            for_each = forward.value.stickiness
            content {
              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration
            }
          }
        }
      }

      dynamic "redirect" {
        for_each = action.value.redirect
        content {
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          query       = redirect.value.query
          status_code = redirect.value.status_code
        }
      }

      dynamic "fixed_response" {
        for_each = action.value.fixed_response
        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }

  dynamic "condition" {
    for_each = lookup(var.listener_rule[count.index], "condition", null)
    content {
      host_header {
        values = condition.value.host_header
      }
      dynamic "http_header" {
        for_each = condition.value.http_header
        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }
      http_request_method {
        values = condition.value.http_request_method
      }
      path_pattern {
        values = condition.value.path_pattern
      }
      dynamic "query_string" {
        for_each = condition.value.query_string
        content {
          key   = condition.value.key
          value = condition.value.value
        }
      }
    }
  }

}

resource "aws_lb_target_group" "this" {
  count                         = length(var.lb_target_group)
  name                          = lookup(var.lb_target_group[count.index], "alb_tg_name", null)
  port                          = lookup(var.lb_target_group[count.index], "alb_tg_port", null)
  protocol                      = lookup(var.lb_target_group[count.index], "alb_tg_protocol", null)
  vpc_id                        = lookup(var.lb_target_group[count.index], "vpc_id", null)
  slow_start                    = lookup(var.lb_target_group[count.index], "slow_start", null)
  load_balancing_algorithm_type = lookup(var.lb_target_group[count.index], "load_balancing_algorithm_type", null)
  target_type                   = lookup(var.lb_target_group[count.index], "target_type", null)

  dynamic "stickiness" {
    for_each = lookup(var.lb_target_group[count.index], "stickiness", null)
    content {
      type            = stickiness.value.type
      cookie_duration = stickiness.value.cookie_duration
      enabled         = stickiness.value.enabled
    }
  }

  dynamic "health_check" {
    for_each = lookup(var.lb_target_group[count.index], "health_check", null)
    content {
      enabled             = health_check.value.enabled
      interval            = health_check.value.interval
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      matcher             = health_check.value.matcher
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${lookup(var.lb_target_group[count.index], "alb_tg_name", null)}-alb-tg"
  }
  depends_on = [aws_lb.this]
}

resource "aws_lb_target_group_attachment" "this" {
  count             = length(var.lb_target_group_attachment)
  target_group_arn  = lookup(var.lb_target_group_attachment[count.index], "target_group_arn", null)
  target_id         = lookup(var.lb_target_group_attachment[count.index], "target_id", null)
  port              = lookup(var.lb_target_group_attachment[count.index], "alb_tg_port", null)
  availability_zone = lookup(var.lb_target_group_attachment[count.index], "availability_zone", null)
  depends_on        = [aws_lb.this]
}