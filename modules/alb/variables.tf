variable "alb_name" {
  description = "Name of the load balancer. Must be unique per region and at most 32 characters."
  type        = string
  default     = null
}

variable "internal" {
  description = "Create an internal load balancer with private addresses only, rather than an internet-facing one."
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Type of load balancer: `application`, `network` or `gateway`."
  type        = string
  default     = null
}
variable "alb_security_groups" {
  description = "Security groups attached to the load balancer. Applies to application load balancers."
  type        = list(string)
  default     = []
}
variable "alb_subnets" {
  description = "Subnets the load balancer is placed in. Use at least two, in different availability zones."
  type        = list(string)
  default     = []
}
variable "idle_timeout" {
  description = "Seconds a connection can be idle before the load balancer closes it. Application load balancers only."
  type        = number
  default     = null
}

variable "enable_deletion_protection" {
  description = "Prevent the load balancer from being deleted. Recommended for production."
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Distribute traffic evenly across all availability zones. Always on for application load balancers, chargeable for network load balancers."
  type        = bool
  default     = false
}

variable "access_logs" {
  description = "Access logging to an S3 bucket. The bucket policy must allow the ELB log delivery account to write."
  type = list(object({
    bucket  = string
    prefix  = string
    enabled = bool
  }))
  default = []
}

variable "subnet_mapping" {
  description = "Subnets with a specific Elastic IP per subnet. Used with network load balancers instead of `alb_subnets`."
  type = list(object({
    subnet_id     = string
    allocation_id = string
  }))
  default = []
}

variable "lb_listener" {
  description = "Listeners for the load balancer. Each entry sets the port and protocol, the TLS policy and certificate for HTTPS, and the default action taken when no listener rule matches."
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


variable "attach_certs_to_alb" {
  description = "Additional certificates attached to an existing HTTPS listener, for serving several domains from one listener."
  type = list(object({
    listener_arn    = string
    certificate_arn = string
  }))
  default = []
}

variable "listener_rule" {
  description = "Listener rules evaluated in `priority` order. Each rule pairs conditions (host header, path pattern and so on) with an action such as forwarding to a target group."
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
  description = "Target groups for the load balancer, including health check settings, stickiness and the load balancing algorithm."
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
  description = "Targets registered into a target group, by instance ID, IP address or Lambda function ARN."
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
