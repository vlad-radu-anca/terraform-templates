variable "comment" {
  description = "Comment stored on the key group in CloudFront."
  type        = string
  default     = ""
}

variable "keys" {
  description = <<-EOT
  Public keys keyed by key name. `file_name` is a path to a PEM-encoded RSA public key file,
  read at plan time with `file()`. The keys are used to verify signed URLs and signed cookies.
  `encoded_key` is ignored after creation, so rotating a key means replacing the entry.
  EOT
  type = map(object({
    file_name = string
    comment   = optional(string)
  }))
  default = {}
}

variable "key_group_name" {
  description = "Name of the key group that bundles the public keys. Reference it from a cache behavior with `trusted_key_groups`."
  type        = string
}
