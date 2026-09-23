########################################
# Naming / tagging
########################################

variable "project_name" {
  description = "Name of the application/project, used as a prefix when naming resources."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod), used as a prefix when naming resources."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to the distribution."
  type        = map(string)
  default     = {}
}

########################################
# Distribution
########################################

variable "enabled" {
  description = "Whether the distribution accepts requests."
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment shown in the CloudFront console."
  type        = string
  default     = null
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) served by the distribution. Requires an ACM certificate in us-east-1."
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "Object returned for a request to the root URL, for example `index.html`."
  type        = string
  default     = null
}

variable "http_version" {
  description = "Maximum HTTP version: `http1.1`, `http2`, `http2and3` or `http3`."
  type        = string
  default     = "http2and3"
}

variable "price_class" {
  description = "Edge locations used: `PriceClass_All`, `PriceClass_200` or `PriceClass_100`."
  type        = string
  default     = "PriceClass_100"
}

variable "ipv6_enabled" {
  description = "Serve the distribution over IPv6 as well as IPv4."
  type        = bool
  default     = true
}

variable "web_acl_id" {
  description = "ARN of a WAFv2 web ACL (must be in us-east-1) or the ID of a WAF Classic ACL."
  type        = string
  default     = null
}

variable "retain_on_delete" {
  description = "Disable the distribution instead of deleting it on destroy."
  type        = bool
  default     = false
}

variable "wait_for_deployment" {
  description = "Wait for the distribution to finish deploying before the apply returns. Deployments take several minutes."
  type        = bool
  default     = true
}

########################################
# Origins
########################################

variable "origins" {
  description = <<-EOT
  Origins keyed by origin ID. Set `type` to `s3` for a bucket, which gets an Origin Access Control
  so the bucket can stay private, or `custom` for anything else, which then needs `custom_origin_config`.
  Use the bucket's regional domain name for S3 origins.
  EOT
  type = map(object({
    domain_name          = string
    type                 = optional(string, "s3")
    origin_path          = optional(string)
    connection_attempts  = optional(number)
    connection_timeout   = optional(number)
    custom_headers       = optional(map(string), {})
    origin_shield_region = optional(string)
    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = optional(string, "https-only")
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
      origin_read_timeout      = optional(number)
      origin_keepalive_timeout = optional(number)
    }))
  }))

  validation {
    condition     = alltrue([for o in var.origins : contains(["s3", "custom"], o.type)])
    error_message = "origin type must be s3 or custom."
  }

  validation {
    condition     = alltrue([for o in var.origins : o.type != "custom" || o.custom_origin_config != null])
    error_message = "custom origins require custom_origin_config."
  }
}

variable "origin_groups" {
  description = "Origin groups keyed by group ID, used for origin failover. `members` lists origin IDs, primary first."
  type = map(object({
    members               = list(string)
    failover_status_codes = optional(list(number), [403, 404, 500, 502, 503, 504])
  }))
  default = {}
}

########################################
# Cache behaviors
########################################

variable "default_cache_behavior" {
  description = <<-EOT
  Default cache behavior. Prefer `cache_policy_name` with a CloudFront managed policy
  (`CachingOptimized`, `CachingDisabled`, `CachingOptimizedForUncompressedObjects`) over passing raw IDs.
  `origin_request_policy_name` controls what reaches the origin, for example `AllViewerExceptHostHeader`.
  `function_associations` maps an event type to a CloudFront Function ARN.
  EOT
  type = object({
    target_origin_id       = string
    viewer_protocol_policy = optional(string, "redirect-to-https")
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    compress               = optional(bool, true)
    smooth_streaming       = optional(bool)

    cache_policy_name            = optional(string, "CachingOptimized")
    cache_policy_id              = optional(string)
    origin_request_policy_name   = optional(string)
    origin_request_policy_id     = optional(string)
    response_headers_policy_name = optional(string, "SecurityHeadersPolicy")
    response_headers_policy_id   = optional(string)

    trusted_key_groups = optional(list(string))
    trusted_signers    = optional(list(string))

    function_associations = optional(map(string), {})
    lambda_function_associations = optional(map(object({
      arn          = string
      include_body = optional(bool, false)
    })), {})
  })
}

variable "ordered_cache_behaviors" {
  description = "Additional cache behaviors, evaluated in order. Same shape as `default_cache_behavior` plus `path_pattern`."
  type = list(object({
    path_pattern           = string
    target_origin_id       = string
    viewer_protocol_policy = optional(string, "redirect-to-https")
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    compress               = optional(bool, true)
    smooth_streaming       = optional(bool)

    cache_policy_name            = optional(string, "CachingOptimized")
    cache_policy_id              = optional(string)
    origin_request_policy_name   = optional(string)
    origin_request_policy_id     = optional(string)
    response_headers_policy_name = optional(string)
    response_headers_policy_id   = optional(string)

    trusted_key_groups = optional(list(string))
    trusted_signers    = optional(list(string))

    function_associations = optional(map(string), {})
    lambda_function_associations = optional(map(object({
      arn          = string
      include_body = optional(bool, false)
    })), {})
  }))
  default = []
}

########################################
# Errors, TLS, restrictions, logging
########################################

variable "custom_error_responses" {
  description = "Custom error responses. Useful for single page apps, which map 403 and 404 to `/index.html` with response code 200."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "viewer_certificate" {
  description = "TLS certificate for the distribution. Leave `acm_certificate_arn` null to use the default `*.cloudfront.net` certificate. ACM certificates must be in us-east-1."
  type = object({
    acm_certificate_arn      = optional(string)
    iam_certificate_id       = optional(string)
    ssl_support_method       = optional(string, "sni-only")
    minimum_protocol_version = optional(string, "TLSv1.2_2021")
  })
  default = {}
}

variable "geo_restriction" {
  description = "Geographic restriction. `restriction_type` is `none`, `whitelist` or `blacklist`, and `locations` holds ISO 3166 country codes."
  type = object({
    restriction_type = optional(string, "none")
    locations        = optional(list(string), [])
  })
  default = {}
}

variable "logging" {
  description = "Standard access logging to an S3 bucket. The bucket must have ACLs enabled, since CloudFront log delivery writes with an ACL."
  type = object({
    bucket          = string
    prefix          = optional(string)
    include_cookies = optional(bool, false)
  })
  default = null
}
