# A production-shaped OpenSearch domain: inside a VPC across two AZs, encrypted with
# a customer-managed key, dedicated masters, fine-grained access control with an IAM
# master user, and all log types published to CloudWatch.

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

locals {
  project_name = "demo"
  environment  = "dev"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "../../../vpc"

  project_name   = local.project_name
  environment    = local.environment
  vpc_cidr_block = "10.50.0.0/16"
  newbits        = 8
}

resource "aws_security_group" "app" {
  name        = "${local.project_name}-${local.environment}-app"
  description = "Application tier allowed to query OpenSearch"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_kms_key" "search" {
  description             = "Encryption key for the ${local.project_name} OpenSearch domain"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

module "opensearch" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment

  engine_version = "OpenSearch_2.17"
  instance_type  = "r6g.large.search"
  instance_count = 2

  dedicated_master = {
    enabled       = true
    instance_type = "m6g.large.search"
    count         = 3
  }

  ebs = {
    volume_size = 100
    volume_type = "gp3"
  }

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = slice(module.vpc.private_subnet_ids, 0, 2)
  allowed_security_group_ids = [aws_security_group.app.id]

  kms_key_id = aws_kms_key.search.arn

  # IAM principal as master user, so no password is stored anywhere.
  fine_grained_access_control = {
    master_user_arn = data.aws_caller_identity.current.arn
  }

  published_log_types   = ["ES_APPLICATION_LOGS", "INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS", "AUDIT_LOGS"]
  log_retention_in_days = 90

  tags = {
    Owner = "platform-team"
  }
}

output "endpoint" {
  description = "Domain endpoint for index and search requests."
  value       = module.opensearch.endpoint
}

output "dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint."
  value       = module.opensearch.dashboard_endpoint
}

output "log_group_arns" {
  description = "Log groups receiving the domain logs."
  value       = module.opensearch.log_group_arns
}
