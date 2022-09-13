variable "codebuild_project" {
  description               = "description"
  type                      = list(string)
  default                   = []
}

variable "artifacts" {
  description               = "Information about the project's build output artifacts."
  type                      = list(object({
    type                    = string
    artifact_identifier     = string
    encryption_disabled     = bool
    override_artifact_name  = bool
    location                = string
    name                    = string
    namespace_type          = string
    packaging               = string
    path                    = string
  }))
  default     = []
}


variable "codebuild_environment" {
  description               = "Information about the project's build environment."
  type                      = list(object({
    compute_type            = string
    image                   = string
    type                    = string
    image_pull_credentials_type  = string
    environment_variable    = list(object({
        name                = string
        value               = string
        type                = string
    }))           
    privileged_mode        = bool
    certificate             = string
  }))
  default     = []
}

variable "logs_config" {
  description               = "Configuration for the builds to store log data to CloudWatch or S3."
  type                      = list(object({
    cloudwatch_logs_status  = string
    cloudwatch_logs_group   = string
    cloudwatch_logs_stream_name  = bool
    s3_logs_status          = bool
    s3_logs_location        = string
    s3_logs_encryption_disabled = string

  }))
  default     = []
}

variable "codebuild_source" {
  description               = "Information about the project's input source code"
  type                      = list(object({
    type                    = string
    auth_type               = string
    resource                = string
    buildspec               = string
    git_clone_depth         = string
    fetch_submodules        = bool
    insecure_ssl            = string
    location                = string
    report_build_status     = bool

  }))
  default     = []
}

variable "build_timeout" {
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. The default is 60 minutes."
  type = string
  default     = null
}

variable "queued_timeout" {
  description = "How long in minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out. The default is 8 hours."
  type = string
  default     = null
}

variable "description" {
  description = "A short description of the project."
  type = string
  default     = null
}

variable "encryption_key" {
  description = "The AWS Key Management Service (AWS KMS) customer master key (CMK) to be used for encrypting the build project's build output artifacts."
  type = string
  default     = null
}
variable "service_role" {
  description = "The Amazon Resource Name (ARN) of the AWS Identity and Access Management (IAM) role that enables AWS CodeBuild to interact with dependent AWS services on behalf of the AWS account."
  type = string
  default     = null
}
variable "source_version" {
  description = "A version of the build input to be built for this project. If not specified, the latest version is used."
  type = string
  default     = null
}

variable "vpc_config" {
  description = "Configuration for the builds to run inside a VPC. VPC config blocks are documented below."
  type        = list(object({
    security_group_ids                    = list(string)
    subnets     = list(string)
    vpc_id     = string
  }))
  default     = []
}

variable "codepipeline_project" {
  description               = "Name of the CodePipeline Projects"
  type                      = list(string)
  default                   = []
}

variable "role_arn" {
  description = "A service role Amazon Resource Name (ARN) that grants AWS CodePipeline permission to make calls to AWS services on your behalf."
  type = string
  default     = null
}

variable "artifact_store" {
  description               = "One or more artifact_store blocks. Artifact stores are documented below."
  type                      = list(object({
    location            = string
    type                   = string
    encryption_key = list(object({
      id          = string          
      type        = string
    }))

    region             = string
  }))
  default     = []
}

variable "stage" {
  description               = "(Minimum of at least two stage blocks is required) A stage block."
  type                      = list(object({
    name = string
    action = list(object({
      category = string
      owner = string
      name= string
      provider = string
      version = string
      configuration  = map(string)
      input_artifacts = list(string)
      output_artifacts= list(string) 
      role_arn= string
      run_order= string
      region= string
      namespace = string
    }))
  }))
  default     = []
}

variable "codestar_notification" {
  type = list(string)
  description = "The name of notification rule"
  default = []
}

variable "detail_type" {
  type = string
  description = "The level of detail to include in the notifications for this resource. Possible values are BASIC and FULL"
  default = null
}

variable "event_type_ids" {
  type = list(string)
  description = "A list of event types associated with this notification rule"
  default = null
}

variable "resource" {
  type = string
  description = "The ARN of the resource to associate with the notification rule."
  default = null
}

variable "status" {
  type = string
  description = "The status of the notification rule. Possible values are ENABLED and DISABLED, default is ENABLED"
  default = null
}

variable "target" {
  type = list(object({
    address = string
    type = string
  }))
  description = "Configuration blocks containing notification target information. Can be specified multiple times. At least one target must be specified on creation."
  default = []
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



