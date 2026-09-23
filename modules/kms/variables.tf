variable "name" {
  description = "Alias for the key, which must start with `alias/`. Use `name_prefix` instead to have a unique alias generated."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Prefix for a generated alias, which must start with `alias/`. Conflicts with `name`."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the key, shown in the KMS console."
  type        = string
  default     = null
}

variable "key_usage" {
  description = "What the key is used for: `ENCRYPT_DECRYPT` (the default), `SIGN_VERIFY` or `GENERATE_VERIFY_MAC`."
  type        = string
  default     = null
}

variable "customer_master_key_spec" {
  description = "Key material and length, for example `SYMMETRIC_DEFAULT`, `RSA_4096` or `ECC_NIST_P384`. Must be compatible with `key_usage`."
  type        = string
  default     = null
}

variable "policy" {
  description = "Key policy as a JSON string. Null applies the AWS default policy, which grants the account root full access."
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Waiting period, in days, before a scheduled key deletion takes effect. Between 7 and 30."
  type        = number
  default     = null
}

variable "is_enabled" {
  description = "Whether the key is enabled and usable for cryptographic operations."
  type        = bool
  default     = null
}

variable "enable_key_rotation" {
  description = "Rotate the key material automatically once a year. Only applies to symmetric keys."
  type        = bool
  default     = true
}
