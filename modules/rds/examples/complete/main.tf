# PostgreSQL on RDS in private subnets, reachable only from an application security group.
# Master password is generated and rotated by RDS in Secrets Manager.

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
  vpc_cidr_block = "10.20.0.0/16"
  newbits        = 8
}

# Whatever will talk to the database (ECS tasks, EKS nodes, a bastion...).
resource "aws_security_group" "app" {
  name        = "${local.project_name}-${local.environment}-app"
  description = "Application tier"
  vpc_id      = module.vpc.vpc_id
}

module "postgres" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.medium"

  allocated_storage     = 20
  max_allocated_storage = 200

  db_name  = "app"
  username = "app_admin"
  # manage_master_user_password defaults to true -> password lives in Secrets Manager

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]

  multi_az            = false # true for production
  deletion_protection = false # true for production
  skip_final_snapshot = true  # false for production

  parameter_group_family = "postgres16"
  parameters = {
    log_min_duration_statement = { value = "1000" }
    "rds.force_ssl"            = { value = "1" }
  }

  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "Sun:03:30-Sun:04:30"

  tags = {
    Owner = "platform-team"
  }
}

# A MySQL instance in the same network, to show engine switching.
module "mysql" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t4g.small"

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]

  parameter_group_family = "mysql8.0"
  parameters = {
    character_set_server     = { value = "utf8mb4" }
    require_secure_transport = { value = "1" }
  }

  performance_insights_enabled = false
  monitoring_interval          = 0
  skip_final_snapshot          = true
}

output "postgres_endpoint" {
  description = "PostgreSQL connection endpoint."
  value       = module.postgres.endpoint
}

output "postgres_secret_arn" {
  description = "Secrets Manager secret holding the PostgreSQL master credentials."
  value       = module.postgres.master_user_secret_arn
}

output "mysql_endpoint" {
  description = "MySQL connection endpoint."
  value       = module.mysql.endpoint
}
