variable "s3_bucket_name" {
  description = "List of Bucket Name"
  type = list(string)
  default = []
}

variable "s3_force_destroy" {
  description = "Want to Delete S3 Bucket from terraform during terraform destroy?"
  type = bool
  default = true
}

variable "s3_policy_document" {
  description = "Add S3 Bucket Policy Document"
  type = string
  default = null
}

variable "s3_acl" {
  description = "The canned ACL to apply. Defaults to private. Conflicts with grant"
  type = string
  default = "private"
}

variable "s3_grant_acl_vars" {
  description =<<-EOT
  s3_acl_grant_type : Type of grantee to apply for. Valid values are CanonicalUser and Group. AmazonCustomerByEmail is not supported
  s3_acl_grant_permission : List of permissions to apply for grantee. Valid values are READ, WRITE, READ_ACP, WRITE_ACP, FULL_CONTROL
  s3_acl_grant_uri : Uri address to grant for. Used only when type is Group
  EOT
  type = list(object({
    s3_acl_grant_type = string
    s3_acl_grant_permission = list(string)
    s3_acl_grant_uri = string
    }))
  default = []
}

variable "acceleration_status" {
  description = "Amazon S3 Transfer Acceleration enables fast, easy, and secure transfers of files over long distances between your client and an S3 bucket"
  type = string
  default = "Suspended"
}


variable "s3_static_website_vars" {
  description =<<-EOT
  index_document : Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders
  error_document : An absolute path to the document to return in case of a 4XX error.
  redirect_all_requests_to : A hostname to redirect all website requests for this bucket to.
  routing_rules : A json array containing routing rules describing redirect behavior and when redirects are applied.
  EOT
  type = object({
    index_document = string
    error_document = string
    redirect_all_requests_to = string
    routing_rules = string
    })
    default = null
}

variable "s3_cors_vars" {
  description =<<-EOT
  allowed_headers : Specifies which headers are allowed
  allowed_methods : Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD
  allowed_origins : Specifies which origins are allowed.
  expose_headers : Specifies expose header in the response.
  max_age_seconds : Specifies time in seconds that browser can cache the response for a preflight request.
  EOT
  type = object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers = list(string)
    max_age_seconds = number
    })
    default = null
}

variable "s3_versioning" {
  type = object({
    enabled = bool
    mfa_delete = bool
    })
  default = null
}

variable "s3_logging" {
  description =<<-EOT
  target_bucket : The name of the bucket that will receive the log objects.
  target_prefix : To specify a key prefix for log objects.
  EOT
   type = object({
     target_bucket = string
     target_prefix = string
     })
   default = null
 }

variable "s3_lifecycle_rule_vars" {
  type = list(object({
    id = string
    prefix = string
    enabled = bool
    transition = list(object({
      days = number
      storage_class = string
      }))
    noncurrent_version_transition = list(object({
      days = number
      storage_class = string
      }))
    noncurrent_version_expiration_days = number
    expiration_days = number
    }))
  default = []
}

variable "environment" {
  description = "Name of Environment"
  type = string
}

variable "project_name" {
  description = "Name of Project"
  type = string
}
