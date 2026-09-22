locals {
  bucket_name = coalesce(var.bucket_name, "${var.project_name}-${var.environment}")

  # BucketOwnerEnforced disables ACLs entirely, which is the recommended setting.
  acls_enabled = var.object_ownership != "BucketOwnerEnforced"

  tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags,
  )
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_prefix == null ? local.bucket_name : null
  bucket_prefix = var.bucket_prefix
  force_destroy = var.force_destroy

  tags = merge(local.tags, { Name = local.bucket_name })
}

########################################
# Ownership, public access, ACL
########################################

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_acl" "this" {
  count = local.acls_enabled && var.acl != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  # Ownership controls must exist before an ACL can be applied.
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

########################################
# Encryption
########################################

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
    # Bucket keys cut KMS request costs substantially and have no downside for SSE-KMS.
    bucket_key_enabled = var.kms_key_id == null ? null : var.bucket_key_enabled
  }
}

########################################
# Versioning
########################################

resource "aws_s3_bucket_versioning" "this" {
  count = var.versioning_enabled != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status     = var.versioning_enabled ? "Enabled" : "Suspended"
    mfa_delete = var.versioning_mfa_delete == null ? null : (var.versioning_mfa_delete ? "Enabled" : "Disabled")
  }
}

########################################
# Lifecycle
########################################

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.key
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = rule.value.prefix
        dynamic "and" {
          for_each = length(rule.value.tags) > 0 ? [1] : []
          content {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days == null && !rule.value.expire_delete_markers ? [] : [1]
        content {
          days                         = rule.value.expiration_days
          expired_object_delete_marker = rule.value.expiration_days == null ? rule.value.expire_delete_markers : null
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days == null ? [] : [1]
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days == null ? [] : [1]
        content {
          days_after_initiation = rule.value.abort_incomplete_multipart_upload_days
        }
      }
    }
  }

  # Lifecycle rules that act on noncurrent versions require versioning to exist first.
  depends_on = [aws_s3_bucket_versioning.this]
}

########################################
# Logging
########################################

resource "aws_s3_bucket_logging" "this" {
  count = var.logging == null ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging.target_bucket
  target_prefix = var.logging.target_prefix
}

########################################
# CORS
########################################

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  count  = length(var.cors_rules) > 0 ? 1 : 0

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

########################################
# Static website
########################################

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.website == null ? 0 : 1

  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.website.index_document == null ? [] : [1]
    content {
      suffix = var.website.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.website.error_document == null ? [] : [1]
    content {
      key = var.website.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website.redirect_all_requests_to == null ? [] : [1]
    content {
      host_name = var.website.redirect_all_requests_to
    }
  }

  routing_rules = var.website.routing_rules
}

########################################
# Transfer acceleration
########################################

resource "aws_s3_bucket_accelerate_configuration" "this" {
  count = var.acceleration_status == null ? 0 : 1

  bucket = aws_s3_bucket.this.id
  status = var.acceleration_status
}

########################################
# Policy
########################################

resource "aws_s3_bucket_policy" "this" {
  count = var.policy == null ? 0 : 1

  bucket = aws_s3_bucket.this.id
  policy = var.policy

  # A policy that grants public read would be rejected before the block is in place.
  depends_on = [aws_s3_bucket_public_access_block.this]
}
