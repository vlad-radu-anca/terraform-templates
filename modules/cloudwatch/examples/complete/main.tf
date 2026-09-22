# Log groups plus a scheduled EventBridge rule and an event-driven one,
# each invoking a target.

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "target_arn" {
  description = "ARN invoked by both rules, for example a Lambda function or an SQS queue."
  type        = string
  default     = "arn:aws:lambda:eu-central-1:123456789012:function:demo-handler"
}

module "cloudwatch" {
  source = "../../"

  project_name = "demo"
  environment  = "dev"

  cloudwatch_log_group_name = [
    "/demo/dev/application",
    "/demo/dev/audit",
  ]
  logs_retention_days = 90

  cloudwatch_event_rule = [
    {
      name                = "demo-dev-nightly"
      description         = "Runs the nightly batch job"
      schedule_expression = "cron(0 2 * * ? *)"
    },
    {
      name        = "demo-dev-ec2-state-change"
      description = "Reacts to EC2 instances entering the stopped state"
      state       = "DISABLED"
      event_pattern = jsonencode({
        source        = ["aws.ec2"]
        "detail-type" = ["EC2 Instance State-change Notification"]
        detail        = { state = ["stopped"] }
      })
    },
  ]

  cloudwatch_event_target = [
    {
      rule      = "demo-dev-nightly"
      target_id = "nightly-handler"
      arn       = var.target_arn
    },
    {
      rule      = "demo-dev-ec2-state-change"
      target_id = "state-change-handler"
      arn       = var.target_arn
    },
  ]
}

output "log_group_arns" {
  description = "ARNs of the created log groups."
  value       = module.cloudwatch.log_group_arns
}

output "event_rule_arns" {
  description = "ARNs of the EventBridge rules."
  value       = module.cloudwatch.event_rule_arns
}
