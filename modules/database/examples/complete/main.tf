# Two Aurora PostgreSQL clusters in the same VPC:
# a provisioned cluster with a writer and two readers, and a Serverless v2 cluster
# that scales to zero when idle. Both use RDS-managed credentials.

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

module "vpc" {
  source = "../../../vpc"

  project_name   = local.project_name
  environment    = local.environment
  vpc_cidr_block = "10.40.0.0/16"
  newbits        = 8
}

resource "aws_security_group" "app" {
  name        = "${local.project_name}-${local.environment}-app"
  description = "Application tier"
  vpc_id      = module.vpc.vpc_id
}

# Provisioned cluster: one writer, two readers across AZs.
module "aurora_provisioned" {
  source = "../../"

  project_name       = local.project_name
  environment        = local.environment
  cluster_identifier = "${local.project_name}-${local.environment}-aurora-pg"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  database_name  = "app"

  instance_class = "db.r6g.large"
  instances = {
    writer   = { promotion_tier = 0 }
    reader-1 = { promotion_tier = 1 }
    reader-2 = { promotion_tier = 1 }
  }

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]

  parameter_group_family = "aurora-postgresql16"
  cluster_parameters = {
    "rds.force_ssl" = { value = "1", apply_method = "pending-reboot" }
  }

  backup_retention_period = 14
  storage_type            = "aurora-iopt1"

  deletion_protection = false # true for production
  skip_final_snapshot = true  # false for production

  tags = {
    Owner = "platform-team"
  }
}

# Serverless v2: scales between 0 and 4 ACUs and pauses after 15 minutes idle.
module "aurora_serverless" {
  source = "../../"

  project_name       = local.project_name
  environment        = local.environment
  cluster_identifier = "${local.project_name}-${local.environment}-aurora-sls"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  database_name  = "app"

  serverlessv2_scaling = {
    min_capacity             = 0
    max_capacity             = 4
    seconds_until_auto_pause = 900
  }

  instances = {
    writer = { promotion_tier = 0 }
  }

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]

  enable_http_endpoint = true # RDS Data API

  performance_insights_enabled = false
  monitoring_interval          = 0
  skip_final_snapshot          = true
}

output "provisioned_writer_endpoint" {
  description = "Writer endpoint of the provisioned cluster."
  value       = module.aurora_provisioned.endpoint
}

output "provisioned_reader_endpoint" {
  description = "Reader endpoint, load balanced across both readers."
  value       = module.aurora_provisioned.reader_endpoint
}

output "provisioned_secret_arn" {
  description = "Secrets Manager secret holding the master credentials."
  value       = module.aurora_provisioned.master_user_secret_arn
}

output "serverless_endpoint" {
  description = "Writer endpoint of the Serverless v2 cluster."
  value       = module.aurora_serverless.endpoint
}
