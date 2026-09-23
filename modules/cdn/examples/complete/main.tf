# A CloudFront distribution in front of a private S3 bucket, with an ALB origin for
# /api/* and an origin group for failover. Uses Origin Access Control and CloudFront
# managed cache policies rather than the legacy OAI and forwarded_values.

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

variable "api_domain_name" {
  description = "Domain name of the API origin, typically an ALB."
  type        = string
  default     = "alb-demo-123456789.eu-central-1.elb.amazonaws.com"
}

locals {
  project_name = "demo"
  environment  = "dev"
}

module "site" {
  source = "../../../s3"

  project_name = local.project_name
  environment  = local.environment
  bucket_name  = "${local.project_name}-${local.environment}-site"
}

module "failover_site" {
  source = "../../../s3"

  project_name = local.project_name
  environment  = local.environment
  bucket_name  = "${local.project_name}-${local.environment}-site-failover"
}

# CloudFront log delivery writes with an ACL, so this bucket keeps ACLs enabled.
module "cdn_logs" {
  source = "../../../s3"

  project_name = local.project_name
  environment  = local.environment
  bucket_name  = "${local.project_name}-${local.environment}-cdn-logs"

  object_ownership = "BucketOwnerPreferred"
  acl              = "log-delivery-write"
}

module "cdn" {
  source = "../../"

  project_name = local.project_name
  environment  = local.environment
  comment      = "Demo distribution"

  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origins = {
    s3-site = {
      domain_name = module.site.bucket_regional_domain_name
      type        = "s3"
    }
    s3-failover = {
      domain_name = module.failover_site.bucket_regional_domain_name
      type        = "s3"
    }
    api = {
      domain_name = var.api_domain_name
      type        = "custom"
      custom_origin_config = {
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
      custom_headers = {
        "X-Origin-Verify" = "demo-shared-secret-goes-in-a-secret-store"
      }
    }
  }

  origin_groups = {
    site-group = {
      members = ["s3-site", "s3-failover"]
    }
  }

  default_cache_behavior = {
    target_origin_id             = "site-group"
    cache_policy_name            = "CachingOptimized"
    response_headers_policy_name = "SecurityHeadersPolicy"
  }

  ordered_cache_behaviors = [
    {
      path_pattern               = "/api/*"
      target_origin_id           = "api"
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cache_policy_name          = "CachingDisabled"
      origin_request_policy_name = "AllViewerExceptHostHeader"
    },
  ]

  # Single page app: serve index.html for client-side routes.
  custom_error_responses = [
    { error_code = 403, response_code = 200, response_page_path = "/index.html" },
    { error_code = 404, response_code = 200, response_page_path = "/index.html" },
  ]

  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["RO", "DE", "NL", "GB"]
  }

  logging = {
    bucket          = "${module.cdn_logs.id}.s3.amazonaws.com"
    prefix          = "cloudfront/"
    include_cookies = false
  }

  tags = {
    Owner = "platform-team"
  }
}

# The bucket policy that lets only this distribution read the private bucket.
data "aws_iam_policy_document" "site_oac" {
  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    actions   = ["s3:GetObject"]
    resources = ["${module.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cdn.arn]
    }
  }
}

output "distribution_domain_name" {
  description = "Domain name of the distribution."
  value       = module.cdn.domain_name
}

output "origin_access_control_ids" {
  description = "Origin access control IDs, keyed by origin."
  value       = module.cdn.origin_access_control_ids
}

output "site_bucket_policy_json" {
  description = "Bucket policy granting the distribution read access to the private site bucket."
  value       = data.aws_iam_policy_document.site_oac.json
}
