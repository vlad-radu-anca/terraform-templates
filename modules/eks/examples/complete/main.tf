# Private EKS cluster with two managed node groups (general on-demand, spot for batch),
# core add-ons, IRSA-ready OIDC provider and access entries for an admin role.

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

variable "admin_role_arn" {
  description = "IAM role that gets cluster-admin via an EKS access entry."
  type        = string
  default     = "arn:aws:iam::123456789012:role/platform-admin"
}

locals {
  project_name = "demo"
  environment  = "dev"
}

module "vpc" {
  source = "../../../vpc"

  project_name   = local.project_name
  environment    = local.environment
  vpc_cidr_block = "10.30.0.0/16"
  newbits        = 8
}

module "eks" {
  source = "../../"

  project_name       = local.project_name
  environment        = local.environment
  kubernetes_version = "1.31"

  subnet_ids = module.vpc.private_subnet_ids

  endpoint_private_access         = true
  endpoint_public_access          = false
  cluster_api_allowed_cidr_blocks = ["10.30.0.0/16"] # VPN / bastion / CI runner ranges

  node_groups = {
    general = {
      instance_types = ["t3.large"]
      desired_size   = 2
      min_size       = 2
      max_size       = 5
      labels         = { workload = "general" }
    }
    spot = {
      instance_types = ["t3.large", "t3a.large", "m5.large"]
      capacity_type  = "SPOT"
      desired_size   = 0
      min_size       = 0
      max_size       = 10
      labels         = { workload = "batch" }
      taints = [{
        key    = "workload"
        value  = "batch"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  access_entries = {
    platform_admin = {
      principal_arn = var.admin_role_arn
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  tags = {
    Owner = "platform-team"
  }
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Run this to connect kubectl to the cluster."
  value       = module.eks.kubeconfig_command
}

output "oidc_provider_arn" {
  description = "Use in IRSA trust policies."
  value       = module.eks.oidc_provider_arn
}
