data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "s3_buket" {
  for_each      = toset(var.s3_bucket_name)
  bucket        = each.value
  force_destroy = var.s3_force_destroy
  acl           = var.s3_grant_acl_vars == null ? var.s3_acl : null

  #Want to Specify S3 grants to Groups or Specific User Account, Use s3_grant_acl_vars
  dynamic "grant" {
    for_each = var.s3_grant_acl_vars == null ? [] : var.s3_grant_acl_vars
    content {
      id          = grant.value.s3_acl_grant_type == "CanonicalUser" ? data.aws_canonical_user_id.current_user.id : null
      type        = grant.value.s3_acl_grant_type
      permissions = grant.value.s3_acl_grant_permission
      uri         = grant.value.s3_acl_grant_uri
    }
  }

  policy              = var.s3_policy_document
  acceleration_status = var.acceleration_status

  dynamic "website" {
    for_each = var.s3_static_website_vars == null ? [] : list(var.s3_static_website_vars)
    content {
      index_document           = website.value.index_document
      error_document           = website.value.error_document
      redirect_all_requests_to = website.value.redirect_all_requests_to
      routing_rules            = website.value.routing_rules
    }
  }

  dynamic "cors_rule" {
    for_each = var.s3_cors_vars == null ? [] : list(var.s3_cors_vars)
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  dynamic "versioning" {
    for_each = var.s3_versioning == null ? [] : list(var.s3_versioning)
    content {
      enabled    = versioning.value.enabled
      mfa_delete = versioning.value.mfa_delete
    }
  }
  dynamic "logging" {
    for_each = var.s3_logging == null ? [] : list(var.s3_logging)
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.s3_lifecycle_rule_vars == null ? [] : var.s3_lifecycle_rule_vars
    content {
      id      = lifecycle_rule.value.id
      prefix  = lifecycle_rule.value.prefix
      enabled = lifecycle_rule.value.enabled

      dynamic "transition" {
        for_each = lifecycle_rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.noncurrent_version_transition
        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      noncurrent_version_expiration {
        days = lifecycle_rule.value.noncurrent_version_expiration_days
      }
      expiration {
        days                         = lifecycle_rule.value.expiration_days
        expired_object_delete_marker = var.s3_versioning == null ? false : true
      }
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${each.value}-s3_bucket"
  }

}
