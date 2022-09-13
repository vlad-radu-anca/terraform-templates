#Want Restricting Access to Amazon S3 Content by Using an Origin Access Identity, so only Cloudfront can access it
#Configure your S3 bucket permissions so that CloudFront can use the OAI to access the files in your bucket and serve them to your users.
#Make sure that users can’t use a direct URL to the S3 bucket to access a file there.
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.comment
}

resource "aws_cloudfront_distribution" "this" {
  aliases             = var.alternate_domain_names
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.distribution_state
  http_version        =  var.max_http_version
  price_class         = var.price_class
  web_acl_id          = var.waf_acl_id

  #Specify either default Cloudfront SSL or Custom ACM SSL
  dynamic "viewer_certificate" {
    for_each            = var.viewer_certificate
    content{
      acm_certificate_arn = viewer_certificate.value.acm_certificate_arn
      cloudfront_default_certificate = viewer_certificate.value.cloudfront_default_certificate
      minimum_protocol_version = viewer_certificate.value.minimum_protocol_version
      iam_certificate_id = viewer_certificate.value.iam_certificate_id
      ssl_support_method = viewer_certificate.value.ssl_support_method
    
    }
  }

  #Specify S3 origin or Cusomt origin
  dynamic "origin" {
    for_each = var.cloudfront_origin
    content{
      dynamic "custom_origin_config" {
        for_each = var.s3_origin_config ? []:origin.value.custom_origin_config
        content{
          http_port = custom_origin_config.value.http_port
          https_port = custom_origin_config.value.https_port
          origin_protocol_policy = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols = custom_origin_config.value.origin_ssl_protocols
        }
      }
      domain_name  = origin.value.domain_name
      origin_id = origin.value.origin_id
      origin_path = origin.value.origin_path
      s3_origin_config {
        origin_access_identity = var.s3_origin_identity_enabled == "Yes" ? aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path:null
      }
    }
  }

  #Multiple Origin Groups with Failover mechanism using "member" parameter
  dynamic "origin_group" {
    for_each = var.cloudfront_origin_group
    content {
      origin_id = origin_group.value.origin_id
      failover_criteria {
        status_codes = origin_group.value.failover_criteria_status_code
      }
      dynamic "member" {
        for_each = origin_group.value.member
        content{
            origin_id = member.value.origin_id
        }
      }
    }
  }

  #One or More Custom Error Responses for Cloudfront Distribution
  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_response == null ? []:var.cloudfront_custom_error_response
    content{
      error_code = custom_error_response.value.error_code
      response_code = custom_error_response.value.response_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      response_page_path = custom_error_response.value.response_page_path
    }
  }

  # Arrange cache behaviors in the order in which you want CloudFront to evaluate them.
  # Default Cache can be Maximum one, and other cache can be oredered as a list @ordered_cache_behavior
  dynamic "default_cache_behavior" {
    for_each = var.cloudfront_default_cache_behavior
    content {
      allowed_methods = default_cache_behavior.value.allowed_http_methods
      cached_methods = default_cache_behavior.value.cached_http_methods
      compress = default_cache_behavior.value.automatically_compress_objects
      default_ttl = default_cache_behavior.value.default_ttl
      max_ttl = default_cache_behavior.value.max_ttl
      min_ttl = default_cache_behavior.value.min_ttl
      smooth_streaming = default_cache_behavior.value.smooth_streaming
      trusted_signers = default_cache_behavior.value.trusted_signers
      trusted_key_groups = default_cache_behavior.value.trusted_key_groups
      target_origin_id = default_cache_behavior.value.target_origin_id
      viewer_protocol_policy = default_cache_behavior.value.viewer_protocol_policy

      #Specifies how CloudFront handles query strings, cookies and headers
      dynamic "forwarded_values" {
        for_each = default_cache_behavior.value.forwarded_values
        content{
          cookies {
            forward = forwarded_values.value.forward_cookies
            whitelisted_names = forwarded_values.value.whitelisted_cookies
          }
          query_string = forwarded_values.value.forward_query_string
          headers = forwarded_values.value.headers
        }
      }

      #A config block that triggers a lambda function with specific actions.
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value.lambda_function_association
        content{
          event_type = lambda_function_association.value.lambda_event_type
          lambda_arn = lambda_function_association.value.lambda_arn
          include_body       = lambda_function_association.value.include_body
        }
      }
    }
  }

  #Multiple Ordered Cache behavior, same as Default except path_pattern exclusion
  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_ordered_cache_behavior
    content{
      path_pattern = ordered_cache_behavior.value.path_pattern
      allowed_methods = ordered_cache_behavior.value.allowed_http_methods
      cached_methods = ordered_cache_behavior.value.cached_http_methods
      compress = ordered_cache_behavior.value.automatically_Compress_objects
      default_ttl = ordered_cache_behavior.value.default_ttl
      max_ttl = ordered_cache_behavior.value.max_ttl
      min_ttl = ordered_cache_behavior.value.min_ttl
      smooth_streaming = ordered_cache_behavior.value.smooth_streaming
      target_origin_id = ordered_cache_behavior.value.target_origin_id
      trusted_signers = ordered_cache_behavior.value.trusted_signers
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy

      #Specifies how CloudFront handles query strings, cookies and headers
      dynamic "forwarded_values" {
        for_each   = ordered_cache_behavior.value.forwarded_values
        content{
          cookies {
            forward = forwarded_values.value.forward_cookies
            whitelisted_names = forwarded_values.value.whitelisted_cookies
          }
          query_string = forwarded_values.value.forward_query_string
          headers = forwarded_values.value.forwarded_values.headers
        }
      }
      #A config block that triggers a lambda function with specific actions.
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association
        content{
          event_type = lambda_function_association.value.lambda_event_type
          lambda_arn = lambda_function_association.value.lambda_arn
          include_body       = lambda_function_association.value.include_body
        }
      }
    }
  }

  #Want to enable Geo Restriction in Cloudfront
  dynamic "restrictions" {
    for_each = var.restrictions
    content {
      geo_restriction {
        locations = restrictions.value.locations
        restriction_type = restrictions.value.restriction_type
      }
    }
  }

  #Specify Bucket Name where you want to upload your Cloudfront access logs
  dynamic "logging_config" {
    for_each = var.cloudfront_logging_config
    content{
      bucket = var.cloudfront_logging_config.s3_bucket_name
      include_cookies = var.cloudfront_logging_config.include_cookies
      prefix = var.cloudfront_logging_config.s3_bucket_name_prefix
    }
  }

  tags = {
        Terraform   = true
        Environment = var.environment
        Name        = "cloudfront_distribution"
    }

}
