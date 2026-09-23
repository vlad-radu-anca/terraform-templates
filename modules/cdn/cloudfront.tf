locals {
  # S3 origins are locked down with an Origin Access Control, which replaced the
  # legacy Origin Access Identity. One OAC per S3 origin.
  s3_origins = { for k, o in var.origins : k => o if o.type == "s3" }

  tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags,
  )
}

########################################
# Managed policies
########################################

# CloudFront managed policies are looked up by name so callers can say
# "CachingOptimized" instead of memorising a UUID.
data "aws_cloudfront_cache_policy" "managed" {
  for_each = toset(compact(concat(
    [var.default_cache_behavior.cache_policy_name],
    [for b in var.ordered_cache_behaviors : b.cache_policy_name],
  )))

  name = each.value
}

data "aws_cloudfront_origin_request_policy" "managed" {
  for_each = toset(compact(concat(
    [var.default_cache_behavior.origin_request_policy_name],
    [for b in var.ordered_cache_behaviors : b.origin_request_policy_name],
  )))

  name = each.value
}

data "aws_cloudfront_response_headers_policy" "managed" {
  for_each = toset(compact(concat(
    [var.default_cache_behavior.response_headers_policy_name],
    [for b in var.ordered_cache_behaviors : b.response_headers_policy_name],
  )))

  name = each.value
}

########################################
# Origin access control
########################################

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = local.s3_origins

  name                              = "${var.project_name}-${var.environment}-${each.key}"
  description                       = "Origin access control for the ${each.key} S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################################
# Distribution
########################################

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  comment             = var.comment
  aliases             = var.aliases
  default_root_object = var.default_root_object
  http_version        = var.http_version
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id
  is_ipv6_enabled     = var.ipv6_enabled
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment

  dynamic "origin" {
    for_each = var.origins
    content {
      origin_id           = origin.key
      domain_name         = origin.value.domain_name
      origin_path         = origin.value.origin_path
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      # S3 origins use an OAC; custom origins use a protocol config. Emitting both
      # on the same origin is rejected by CloudFront.
      origin_access_control_id = origin.value.type == "s3" ? aws_cloudfront_origin_access_control.this[origin.key].id : null

      dynamic "custom_origin_config" {
        for_each = origin.value.type == "custom" ? [origin.value.custom_origin_config] : []
        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield_region == null ? [] : [1]
        content {
          enabled              = true
          origin_shield_region = origin.value.origin_shield_region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = var.origin_groups
    content {
      origin_id = origin_group.key

      failover_criteria {
        status_codes = origin_group.value.failover_status_codes
      }

      dynamic "member" {
        for_each = origin_group.value.members
        content {
          origin_id = member.value
        }
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    compress               = var.default_cache_behavior.compress
    smooth_streaming       = var.default_cache_behavior.smooth_streaming

    # Cache policies replace the legacy forwarded_values block.
    cache_policy_id            = try(data.aws_cloudfront_cache_policy.managed[var.default_cache_behavior.cache_policy_name].id, var.default_cache_behavior.cache_policy_id)
    origin_request_policy_id   = try(data.aws_cloudfront_origin_request_policy.managed[var.default_cache_behavior.origin_request_policy_name].id, var.default_cache_behavior.origin_request_policy_id)
    response_headers_policy_id = try(data.aws_cloudfront_response_headers_policy.managed[var.default_cache_behavior.response_headers_policy_name].id, var.default_cache_behavior.response_headers_policy_id)

    trusted_key_groups = var.default_cache_behavior.trusted_key_groups
    trusted_signers    = var.default_cache_behavior.trusted_signers

    dynamic "function_association" {
      for_each = var.default_cache_behavior.function_associations
      content {
        event_type   = function_association.key
        function_arn = function_association.value
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior.lambda_function_associations
      content {
        event_type   = lambda_function_association.key
        lambda_arn   = lambda_function_association.value.arn
        include_body = lambda_function_association.value.include_body
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress
      smooth_streaming       = ordered_cache_behavior.value.smooth_streaming

      cache_policy_id            = try(data.aws_cloudfront_cache_policy.managed[ordered_cache_behavior.value.cache_policy_name].id, ordered_cache_behavior.value.cache_policy_id)
      origin_request_policy_id   = try(data.aws_cloudfront_origin_request_policy.managed[ordered_cache_behavior.value.origin_request_policy_name].id, ordered_cache_behavior.value.origin_request_policy_id)
      response_headers_policy_id = try(data.aws_cloudfront_response_headers_policy.managed[ordered_cache_behavior.value.response_headers_policy_name].id, ordered_cache_behavior.value.response_headers_policy_id)

      trusted_key_groups = ordered_cache_behavior.value.trusted_key_groups
      trusted_signers    = ordered_cache_behavior.value.trusted_signers

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_associations
        content {
          event_type   = function_association.key
          function_arn = function_association.value
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_associations
        content {
          event_type   = lambda_function_association.key
          lambda_arn   = lambda_function_association.value.arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.viewer_certificate.acm_certificate_arn == null
    acm_certificate_arn            = var.viewer_certificate.acm_certificate_arn
    iam_certificate_id             = var.viewer_certificate.iam_certificate_id
    ssl_support_method             = var.viewer_certificate.acm_certificate_arn == null ? null : var.viewer_certificate.ssl_support_method
    minimum_protocol_version       = var.viewer_certificate.acm_certificate_arn == null ? null : var.viewer_certificate.minimum_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  dynamic "logging_config" {
    for_each = var.logging == null ? [] : [1]
    content {
      bucket          = var.logging.bucket
      prefix          = var.logging.prefix
      include_cookies = var.logging.include_cookies
    }
  }

  tags = merge(local.tags, { Name = "${var.project_name}-${var.environment}-cdn" })
}
