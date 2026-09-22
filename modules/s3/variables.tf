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

variable "bucket_name" {
  description = "Bucket name. Defaults to `<project_name>-<environment>`. Ignored when `bucket_prefix` is set."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "Generate a unique bucket name with this prefix instead of using `bucket_name`."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Delete all objects when the bucket is destroyed. Keep false for anything holding real data."
  type        = bool
  default     = false
}

########################################
# Access control
########################################

variable "object_ownership" {
  description = "Object ownership: `BucketOwnerEnforced` (ACLs disabled, recommended), `BucketOwnerPreferred` or `ObjectWriter`."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter."
  }
}

variable "block_public_access" {
  description = "Apply all four public access blocks. Only set to false for a bucket that is deliberately public, such as a static website origin."
  type        = bool
  default     = true
}

variable "acl" {
  description = "Canned ACL to apply. Only used when `object_ownership` is not `BucketOwnerEnforced`, because that setting disables ACLs."
  type        = string
  default     = null
}

variable "policy" {
  description = "Bucket policy as a JSON string, typically from an `aws_iam_policy_document`."
  type        = string
  default     = null
}

########################################
# Encryption
########################################

variable "kms_key_id" {
  description = "KMS key ARN or ID for SSE-KMS encryption. Null uses SSE-S3 (`AES256`)."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Use an S3 bucket key with SSE-KMS, which reduces KMS request costs. Ignored for SSE-S3."
  type        = bool
  default     = true
}

########################################
# Versioning
########################################

variable "versioning_enabled" {
  description = "Enable object versioning. Null leaves versioning unmanaged by this module."
  type        = bool
  default     = null
}

variable "versioning_mfa_delete" {
  description = "Require MFA to delete object versions. Only meaningful when versioning is enabled, and can only be changed by the bucket owner with MFA."
  type        = bool
  default     = null
}

########################################
# Lifecycle
########################################

variable "lifecycle_rules" {
  description = <<-EOT
  Lifecycle rules keyed by rule ID. `prefix` limits the rule to a key prefix, `tags` narrows it further.
  `expire_delete_markers` removes delete markers left behind once all noncurrent versions expire.
  EOT
  type = map(object({
    enabled = optional(bool, true)
    prefix  = optional(string)
    tags    = optional(map(string), {})
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration_days                        = optional(number)
    expire_delete_markers                  = optional(bool, false)
    noncurrent_version_expiration_days     = optional(number)
    abort_incomplete_multipart_upload_days = optional(number, 7)
  }))
  default = {}
}

########################################
# Logging / CORS / website / acceleration
########################################

variable "logging" {
  description = "Send server access logs to another bucket. The target bucket must grant write access to the S3 logging service."
  type = object({
    target_bucket = string
    target_prefix = optional(string, "")
  })
  default = null
}

variable "cors_rules" {
  description = "CORS rules for the bucket."
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website" {
  description = <<-EOT
  Static website configuration. Set either `index_document` (with an optional `error_document`)
  or `redirect_all_requests_to`. `routing_rules` is a JSON string.
  EOT
  type = object({
    index_document           = optional(string)
    error_document           = optional(string)
    redirect_all_requests_to = optional(string)
    routing_rules            = optional(string)
  })
  default = null
}

variable "acceleration_status" {
  description = "Transfer acceleration: `Enabled` or `Suspended`. Null leaves it unmanaged."
  type        = string
  default     = null
}
