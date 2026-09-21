variable "filename" {
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options cannot be used."
  type        = string
  default     = null
}

variable "function_name" {
  description = "A unique name for your Lambda Function."
  type        = list(string)
  default     = []
}

variable "s3_bucket" {
  description = "The S3 bucket location containing the function's deployment package. Conflicts with filename. This bucket must reside in the same AWS region where you are creating the Lambda function."
  type        = string
  default     = null

}

variable "s3_key" {
  description = " The S3 key of an object containing the function's deployment package. Conflicts with filename."
  type        = string
  default     = null

}

variable "s3_object_version" {
  description = "The object version containing the function's deployment package. Conflicts with filename."
  type        = string
  default     = null

}



variable "handler" {
  description = "The function entrypoint in your code."
  type        = string
  default     = null

}

variable "role" {
  description = "IAM role attached to the Lambda Function. This governs both who / what can invoke your Lambda Function, as well as what resources our Lambda Function has access to. "
  type        = string
  default     = null

}

variable "description" {
  description = "Description of what your Lambda Function does."
  type        = string
  default     = null

}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. "
  type        = list(string)
  default     = []

}

variable "memory_size" {
  description = " Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128"
  type        = number
  default     = null

}

variable "runtime" {
  description = "See Runtimes for valid values."
  type        = string
  default     = null

}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds. Defaults to 3"
  type        = number
  default     = null

}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1"
  type        = number
  default     = null

}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version. Defaults to false."
  type        = bool
  default     = null

}

variable "vpc_config" {
  description = "Provide this to allow your function to access your VPC."
  type = list(object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  }))
  default = []

}

variable "environment_vars" {
  description = "The Lambda environment's configuration settings."
  type = list(object({
    variables = any
  }))
  default = []

}

variable "kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key. If this configuration is provided when environment variables are not in use, the AWS Lambda API does not save this configuration and Terraform will show a perpetual difference of adding the key. To fix the perpetual difference, remove this configuration."
  type        = string
  default     = null

}

variable "source_code_hash" {
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key."
  type        = string
  default     = null

}


variable "file_system_config" {
  description = "The connection settings for an EFS file system. Fields documented below. Before creating or updating Lambda functions with file_system_config, EFS mount targets much be in available lifecycle state. Use depends_on to explicitly declare this dependency. "
  type = list(object({
    arn              = string
    local_mount_path = string
  }))
  default = []

}

variable "lambda_permission" {
  description = ""
  type = list(object({
    action              = string
    event_source_token  = string
    function_name       = string
    principal           = string
    qualifier           = string
    source_account      = string
    source_arn          = string
    statement_id        = string
    statement_id_prefix = string
  }))
  default = []

}
