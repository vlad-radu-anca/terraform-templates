# Three buckets that between them exercise every feature of the module:
# a private data bucket with KMS, versioning and lifecycle tiering, a log target,
# and a public static website with CORS.

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

# Target for server access logs. S3 log delivery writes with an ACL, so this
# bucket keeps ACLs enabled rather than using BucketOwnerEnforced.
module "logs" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment
  bucket_name  = "${local.project_name}-${local.environment}-access-logs"

  object_ownership = "BucketOwnerPreferred"
  acl              = "log-delivery-write"

  lifecycle_rules = {
    expire-old-logs = {
      expiration_days = 90
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
      ]
    }
  }
}

# Primary data bucket: encrypted with KMS, versioned, tiered, and logged.
module "data" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment
  bucket_name  = "${local.project_name}-${local.environment}-data"

  kms_key_id         = aws_kms_key.s3.arn
  versioning_enabled = true

  logging = {
    target_bucket = module.logs.id
    target_prefix = "data/"
  }

  lifecycle_rules = {
    tier-and-expire = {
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER_IR" },
      ]
      noncurrent_version_transitions = [
        { days = 30, storage_class = "GLACIER" },
      ]
      noncurrent_version_expiration_days = 365
      expire_delete_markers              = true
    }
    clean-tmp = {
      prefix          = "tmp/"
      expiration_days = 7
    }
  }

  tags = {
    Owner          = "platform-team"
    DataClassified = "internal"
  }
}

resource "aws_kms_key" "s3" {
  description             = "Encryption key for the ${local.project_name} data bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Static website. Public access blocks are deliberately off here, which is the
# only situation where that is appropriate.
module "website" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment
  bucket_name  = "${local.project_name}-${local.environment}-website"

  block_public_access = false
  policy              = data.aws_iam_policy_document.website_public_read.json

  website = {
    index_document = "index.html"
    error_document = "404.html"
  }

  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3600
    }
  ]
}

data "aws_iam_policy_document" "website_public_read" {
  statement {
    sid       = "PublicRead"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.project_name}-${local.environment}-website/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

output "data_bucket_arn" {
  description = "ARN of the encrypted data bucket."
  value       = module.data.arn
}

output "data_bucket_regional_domain_name" {
  description = "Regional domain name, usable as a CloudFront origin."
  value       = module.data.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Static website endpoint."
  value       = module.website.website_endpoint
}
