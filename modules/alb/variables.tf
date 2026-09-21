variable "health_check_config" {
  description = "description"
  type = list(object({
    failure_threshold = number
    resource_path     = string
    type              = string
  }))
  default = []
}



variable "health_check_custom_config" {
  description = "description"
  type = list(object({
    failure_threshold = number
  }))
  default = []
}

variable "alb_name" {
  description = "description"
  type        = string
  default     = null
}

variable "internal" {
  description = "description"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "description"
  type        = string
  default     = null
}
variable "alb_security_groups" {
  description = "description"
  type        = list(string)
  default     = []
}
variable "alb_subnets" {
  description = "description"
  type        = list(string)
  default     = []
}
variable "idle_timeout" {
  description = "description"
  type        = number
  default     = null
}

variable "enable_deletion_protection" {
  description = "description"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "description"
  type        = bool
  default     = false
}

variable "access_logs" {
  description = "description"
  type = list(object({
    bucket  = string
    prefix  = string
    enabled = bool
  }))
  default = []
}

variable "subnet_mapping" {
  description = "description"
  type = list(object({
    subnet_id     = string
    allocation_id = string
  }))
  default = []
}

variable "lb_listener" {
  description = "description"
  type = list(object({
    load_balancer_arn     = string
    alb_listener_port     = number
    alb_listener_protocol = string
    ssl_policy            = string
    certificate_arn       = string
    default_action = list(object({
      type             = string
      target_group_arn = string
      forward = list(object({
        target_group = list(object({
          arn    = string
          weight = number
        }))
        stickiness = list(object({
          enabled  = bool
          duration = number
        }))
      }))
      redirect = list(object({
        host        = string
        path        = string
        port        = string
        protocol    = string
        query       = string
        status_code = string
      }))
      fixed_response = list(object({
        content_type = string
        message_body = string
        status_code  = string
      }))
    }))
  }))
  default = []
}


/*
variable "load_balancer_arn" {
  description = "description"
  type        = string
  default     = null
}

variable "alb_listener_port" {
  description = "description"
  type        = number
  default     = null
}

variable "alb_listener_protocol" {
  description = "description"
  type        = string
  default     = "HTTP"
}

variable "ssl_policy" {
  description = "description"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "description"
  type        = string
  default     = null
}

variable "default_action" {
  description = "description"
  type        = list(object({
    type = string
    target_group_arn = string
    forward = list(object({
      target_group = list(object({
        arn = string
        weight = number
      }))
      stickiness = list(object({
        enabled = bool
        duration = number
      }))
    }))
    redirect = list(object({
        host = string
        path = string
        port = string
        protocol = string
        query = string
        status_code = string
    }))
    fixed_response = list(object({
        content_type = string
        message_body = string
        status_code = string
    }))
  }))
  default     = []
}

*/
variable "attach_certs_to_alb" {
  description = "description"
  type = list(object({
    listener_arn    = string
    certificate_arn = string
  }))
  default = []
}

variable "listener_rule" {
  description = "description"
  type = list(object({
    listener_arn = string
    priority     = string
    action = list(object({
      type             = string
      target_group_arn = string
      forward = list(object({
        target_group = list(object({
          arn    = string
          weight = number
        }))
        stickiness = list(object({
          enabled  = bool
          duration = number
        }))
      }))
      redirect = list(object({
        host        = string
        path        = string
        port        = string
        protocol    = string
        query       = string
        status_code = string
      }))
      fixed_response = list(object({
        content_type = string
        message_body = string
        status_code  = string
      }))
    }))
    condition = list(object({
      host_header = list(string)
      http_header = list(object({
        http_header_name = string
        values           = list(string)
      }))
      http_request_method = list(string)
      path_pattern        = string
      key                 = string
      value               = string
    }))
  }))
  default = []
}

variable "lb_target_group" {
  description = "description"
  type = list(object({
    alb_tg_name                   = string
    alb_tg_port                   = number
    alb_tg_protocol               = string
    vpc_id                        = string
    slow_start                    = string
    load_balancing_algorithm_type = string
    target_type                   = string
    stickiness = list(object({
      type            = string
      cookie_duration = number
      enabled         = bool
    }))
    health_check = list(object({
      enabled             = bool
      interval            = number
      path                = string
      port                = number
      protocol            = string
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      matcher             = string
    }))
  }))
  default = []
}

variable "lb_target_group_attachment" {
  description = "description"
  type = list(object({
    target_group_arn  = string
    target_id         = string
    alb_tg_port       = number
    availability_zone = string
  }))
  default = []
}



variable "environment" {
  type        = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default     = "testing"
}

variable "project_name" {
  type        = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default     = "asgard-infra-templates"
}
