variable "alternate_domain_names" {
  description = "Extra CNAMEs"
  type = list(string)
  default = []
}

variable "comment" {
  description = "Any comments you want to include about the distribution."
  type = string
  default = null
}
variable "default_root_object" {
  description = "The object that you want CloudFront to return"
  type = string
  default = null
  
}

variable "distribution_state" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type = bool
  default = null
}

variable "max_http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2"
  type = string
  default = null
}

variable "price_class" {
  description = "(optional) describe your variable"
  type = string
  default = null
}

variable "waf_acl_id" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type = string
  default = null
}


#Specify either default Cloudfront SSL or Custom ACM SSL
variable "viewer_certificate" {
  description =<<-EOT
  acm_certificate_arn : ACM arn
  cloudfront_default_certificaten : if you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution.
  minimum_protocol_version : One of SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016 or TLSv1.2_2018. Default: TLSv1
  EOT
  type = list(object({
  acm_certificate_arn = string
  cloudfront_default_certificate = bool
  minimum_protocol_version = string
  iam_certificate_id = string
  ssl_support_method = string
  }))
  default = []
}

variable "s3_origin_config" {
  description = "If an S3 origin is required, specify true."
  type = bool
  default = false

}
#Specify S3 origin or Cusomt origin
variable "cloudfront_origin" {
  description =<<-EOT
  http_port : The HTTP port the custom origin listens on
  https_port : The HTTPS port the custom origin listens on
  origin_protocol_policy : The origin protocol policy to apply to your origin. One of http-only, https-only, or match-viewer
  origin_ssl_protocols : A list of one or more of SSLv3, TLSv1, TLSv1.1, and TLSv1.2
  domain_name : The DNS domain name of either the S3 bucket, or web site of your custom
  origin_id : A unique identifier for the origin
  origin_path : An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin
  EOT
  type = list(object({
    custom_origin_config = list(object({
      http_port = string
      https_port = string
      origin_protocol_policy = string
      origin_ssl_protocols = list(string)
      }))
    domain_name = string
    origin_id = string
    origin_path = string
    }))
    default = []
}

#Multiple Origin Groups with Failover mechanism using "member" parameter
variable "cloudfront_origin_group" {
  description =<<-EOT
  origin_id : A unique identifier for the origin group
  failover_criteria_status_code : The failover criteria for when to failover to the secondary origin
  member : Ordered member configuration blocks assigned to the origin group, where the first member is the primary origin. You must specify two members.
  EOT
  type = list(object({
    origin_id    = string
    failover_criteria_status_code = list(string)
    member = list(object({
      origin_id = string
      }))
    }))
    default = []
}

#Custom Error Page and Responses you want Cloudfront to redirect
variable "cloudfront_custom_error_response" {
  description =<<-EOT
  error_code : The minimum amount of time you want HTTP error codes to stay
  response_code : The 4xx or 5xx HTTP status code that you want to customize.
  error_caching_min_ttl : The HTTP status code that you want CloudFront to return with the custom error page to the viewer.
  response_page_path : The path of the custom error page (for example, /custom_404.html).
 EOT
  type = list(object({
     error_code = string
     response_code = string
     error_caching_min_ttl = string
     response_page_path = string
     }))
    default = []
}

# Default Cache, can be Maximum one,
variable "cloudfront_default_cache_behavior" {
  description =<<-EOT
  path_pattern : Specifies which requests you want this cache behavior to apply to.
  allowed_http_methods : Controls which HTTP methods CloudFront processes and forwards
  cached_http_methods : Controls whether CloudFront caches the response to requests using the specified HTTP methods, two options:  GET and HEAD, GET, HEAD, and OPTIONS requests.
  automatically_Compress_objects : Want CloudFront to automatically compress content for web requests
  default_ttl : Default time object is in Cache
  smooth_streaming : whether you want to distribute media files in Microsoft Smooth Streaming format
  trusted_signers : The AWS accounts, if any, that you want to allow to create signed URLs for private content.
  viewer_protocol_policy : One of allow-all, https-only, or redirect-to-https
  EOT
  type = list(object({
    allowed_http_methods = list(string)
    cached_http_methods = list(string)
    automatically_compress_objects = bool
    default_ttl = number
    max_ttl  = number
    min_ttl = number
    smooth_streaming = bool
    trusted_signers = list(string)
    trusted_key_groups = list(string)
    target_origin_id = string
    viewer_protocol_policy = string
    #Specifies how CloudFront handles query strings, cookies and headers
    forwarded_values = list(object({
      forward_cookies = string
      whitelisted_cookies = set(string)
      forward_query_string = bool
      headers =  set(string)
      })),
    #A config block that triggers a lambda function with specific actions
    lambda_function_association = list(object({
      lambda_event_type = string
      lambda_arn = string
      include_body = bool
      }))
    }))
  default = []
}

#Multiple Ordered Cache Behavior
variable "cloudfront_ordered_cache_behavior" {
  description =<<-EOT
  path_pattern : Specifies which requests you want this cache behavior to apply to.
  allowed_http_methods : Controls which HTTP methods CloudFront processes and forwards
  cached_http_methods : Controls whether CloudFront caches the response to requests using the specified HTTP methods
  automatically_Compress_objects : Want CloudFront to automatically compress content for web requests
  default_ttl : Default time object is in Cache
  smooth_streaming : whether you want to distribute media files in Microsoft Smooth Streaming format
  trusted_signers : The AWS accounts, if any, that you want to allow to create signed URLs for private content.
  viewer_protocol_policy : One of allow-all, https-only, or redirect-to-https
  EOT
  type = list(object({
    path_pattern = string
    allowed_http_methods = list(string)
    cached_http_methods = list(string)
    automatically_Compress_objects = bool
    default_ttl = number
    max_ttl  = number
    min_ttl = number
    smooth_streaming = bool
    trusted_signers = string
    target_origin_id = string
    viewer_protocol_policy = string
    #Specifies how CloudFront handles query strings, cookies and headers
    forwarded_values = list(object({
      forward_cookies = string
      whitelisted_cookies = string
      forward_query_string = string
      headers =  string
      }))
    #A config block that triggers a lambda function with specific actions
    lambda_function_association = list(object({
      lambda_event_type = string
      lambda_arn = string
      include_body = bool
      }))
    }))
  default = []
}
#Want to enable Geo Restriction in Cloudfront
variable "restrictions" {
  description =<<-EOT
  locations : The ISO 3166-1-alpha-2  locations code
  restriction_type : Restrict distribution of your content by country: none, whitelist, or blacklist.
  EOT
  type = list(object({
    locations = list(string)
    restriction_type = string
    }))
  default = []
}

#controls how logs are written to your distribution
variable "cloudfront_logging_config" {
  description =<<-EOT
  s3_bucket_name : The Amazon S3 bucket to store the access logs in
  include_cookies :  Specifies whether you want CloudFront to include cookies in access logs
  s3_bucket_name_prefix : An optional string that you want CloudFront to prefix to the access log filenames
  EOT
  type = list(object({
    s3_bucket_name = string
    include_cookies = bool
    s3_bucket_name_prefix = string
    }))
    default = []
}

#Want Restricting Access to Amazon S3 Content by Using an Origin Access Identity, so only Cloudfront can access it
#Configure your S3 bucket permissions so that CloudFront can use the OAI to access the files in your bucket and serve them to your users.
#Make sure that users can’t use a direct URL to the S3 bucket to access a file there.
variable "s3_origin_identity_enabled" {
  type = string
  description = "S3 Origin ?"
  default = "Yes"
}

variable "environment" {
  type = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default = "testing"
}

variable "project_name" {
  type = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default = "asgard-infra-templates"
}

