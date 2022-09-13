variable "admin_create_user_config" {
  description = "The configuration for AdminCreateUser requests."
  type = list(object({
      allow_admin_create_user_only = bool
      invite_message_template = list(object({
        email_message = string
        email_subject = string
        sms_message = string
      }))
  }))
  default = []
}

variable "alias_attributes" {
  description = "Attributes supported as an alias for this user pool. Possible values: phone_number, email, or preferred_username. Conflicts with username_attributes."
  type = set(string)
  default = null
}

variable "auto_verified_attributes" {
  description = "The attributes to be auto-verified. Possible values: email, phone_number."
  type = list(string)
  default = []
}

variable "device_configuration" {
  description = "The configuration for the user pool's device tracking."
  type = list(object({
    challenge_required_on_new_device = bool
     device_only_remembered_on_user_prompt = bool
  }))
  default = []
}

variable "email_configuration" {
  description = " The Email Configuration."
  type = list(object({
    reply_to_email_address = string
    source_arn = string
    from_email_address = string
    email_sending_account = string
  }))
  default = []
}

variable "user_pool_name" {
  description = "The name of the user pool."
  type = list(string)
  default = []
}

variable "email_verification_subject" {
  description = "A string representing the email verification subject. Conflicts with verification_message_template configuration block email_subject argument."
  type = string
  default = null
}

variable "email_verification_message" {
  description = " A string representing the email verification message. Conflicts with verification_message_template configuration block email_message argument."
  type = string
  default = null
}

variable "lambda_config" {
  description = "A container for the AWS Lambda triggers associated with the user pool."
  type = list(object({
    create_auth_challenge = string
    custom_message = string
    define_auth_challenge = string
    post_authentication = string
    post_confirmation = string
    pre_authentication = string
    pre_sign_up = string
    pre_token_generation = string
    user_migration = string
    verify_auth_challenge_response = string
  }))
  default = []
}

variable "mfa_configuration" {
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool."
  type = string
  default = null
}

variable "password_policy" {
  description = "A container for information about the user pool password policy."
  type = list(object({
    minimum_length = number
    require_lowercase = bool
    require_numbers = bool
    require_symbols = bool
    require_uppercase = bool
    temporary_password_validity_days = number
  }))
  default = []
}

variable "schema" {
  description = "A container with the schema attributes of a user pool. Schema attributes from the standard attribute set only need to be specified if they are different from the default configuration. Maximum of 50 attributes."
  type = list(object({
    attribute_data_type = string
    developer_only_attribute = bool
    mutable = bool
    name = string
    number_attribute_constraints = list(object({
        max_value = number
        min_value = number
    }))
    required = bool
    string_attribute_constraints = list(object({
        max_length = number
        min_length = number
    }))
  }))
  default = []
}

variable "sms_authentication_message" {
  description = "A string representing the SMS authentication message. The message must contain the {####} placeholder, which will be replaced with the code."
  type = string
  default = null
}

variable "sms_configuration" {
  description = "Configuration block for Short Message Service (SMS) settings."
  type = list(object({
    external_id = string
    sns_caller_arn = string
  }))
  default = []
}

variable "sms_verification_message" {
  description = "A string representing the SMS verification message. Conflicts with verification_message_template configuration block sms_message argument."
  type = string
  default = null
}

variable "software_token_mfa_configuration" {
  description = "Configuration block for software token Mult-Factor Authentication (MFA) settings. "
  type = list(object({
    enabled = bool
  }))
  default = []
}

variable "username_attributes" {
  description = "Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with alias_attributes."
  type = list(string)
  default = []
}

variable "username_configuration" {
  description = "The Username Configuration."
  type = list(object({
    case_sensitive = bool
  }))
  default = []
}

variable "user_pool_add_ons" {
  description = "Configuration block for user pool add-ons to enable user pool advanced security mode features."
  type = list(object({
    advanced_security_mode = string
  }))
  default = []
}


variable "verification_message_template" {
  description = "The verification message templates"
  type = list(object({
    default_email_option = string
    email_message = string
    email_message_by_link = string
    email_subject = string
    email_subject_by_link = string
    sms_message = string
  }))
  default = []
}

variable "account_recovery_setting" {
  description = "The account_recovery_setting configuration."
  type = list(object({
    name = string
    priority = number
  }))
  default = []
}

variable "identity_pool_name" {
  description = "The Cognito Identity Pool name."
  type = list(string)
  default     = []
}

variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins or not."
  type = bool
  default     = null
}

variable "developer_provider_name" {
  description = "The domain by which Cognito will refer to your users. This name acts as a placeholder that allows your backend and the Cognito service to communicate about the developer provider."
  type = string
  default     = null
}

variable "cognito_identity_providers" {
  description = "An array of Amazon Cognito Identity user pools and their client IDs."
  type = list(object({
    client_id = string
    provider_name = string
    server_side_token_check = bool
  }))
  default     = []
}

variable "saml_provider_arns" {
  description = "An array of Amazon Resource Names (ARNs) of the SAML provider for your identity."
  type = list(string)
  default     = []
}

variable "supported_login_providers" {
  description = "Key-Value pairs mapping provider names to provider app IDs."
  type = any
  default     = null
}

variable "user_pool_domain" {
  description = "The domain string."
  type = list(string)
  default     = null
}


variable "user_pool_id" {
  description = " The user pool ID."
  type = string
  default     = null
}

variable "certificate_arn" {
  description = "The ARN of an ISSUED ACM certificate in us-east-1 for a custom domain."
  type = string
  default     = null
}


variable "identity_pool_id" {
  description = "An identity pool ID in the format REGION:GUID."
  type = string
  default     = null
}


variable "role_mapping" {
  description = "A List of Role Mapping."
  type = list(object({
    identity_provider = string
    ambiguous_role_resolution = string
    mapping_rule = list(object({
      claim = string
      role_arn = string
      value = string
    }))
  }))
  default     = []
}


variable "roles" {
  description = "The map of roles associated with this pool. For a given role, the key will be either 'authenticated' or 'unauthenticated' and the value will be the Role ARN."
  type = any
  default     = null
}

variable "environment" {
  type = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default = "testing"
}

variable "project_name" {
  type = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default = "makeen-infra-templates"
}