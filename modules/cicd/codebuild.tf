resource "aws_codebuild_project" "this" {
  for_each = toset(var.codebuild_project)
  name     = each.value
  dynamic "artifacts" {
    for_each = var.artifacts
    content {
      type                   = artifacts.value.type
      artifact_identifier    = artifacts.value.artifact_identifier
      encryption_disabled    = artifacts.value.encryption_disabled
      override_artifact_name = artifacts.value.override_artifact_name
      location               = artifacts.value.location
      name                   = artifacts.value.name
      namespace_type         = artifacts.value.namespace_type
      packaging              = artifacts.value.packaging
      path                   = artifacts.value.path
    }
  }
  dynamic "environment" {
    for_each = var.codebuild_environment
    content {
      compute_type                = environment.value.compute_type
      image                       = environment.value.image
      type                        = environment.value.type
      image_pull_credentials_type = environment.value.image_pull_credentials_type
      dynamic "environment_variable" {
        for_each = environment.value.environment_variable
        content {
          name  = environment_variable.value.name
          value = environment_variable.value.value
          type  = environment_variable.value.type
        }
      }
      privileged_mode = environment.value.privileged_mode
      certificate     = environment.value.certificate
    }
  }

  dynamic "logs_config" {
    for_each = var.logs_config
    content {
      cloudwatch_logs {
        status      = logs_config.value.cloudwatch_logs_status
        group_name  = logs_config.value.cloudwatch_logs_group
        stream_name = logs_config.value.cloudwatch_logs_stream_name
      }
      s3_logs {
        status              = logs_config.value.s3_logs_status
        location            = logs_config.value.s3_logs_location
        encryption_disabled = logs_config.value.s3_logs_encryption_disabled
      }
    }
  }

  dynamic "source" {
    for_each = var.codebuild_source
    content {
      type = source.value.type
      auth {
        type     = source.value.auth_type
        resource = source.value.resource
      }
      buildspec       = source.value.buildspec
      git_clone_depth = source.value.git_clone_depth
      git_submodules_config {
        fetch_submodules = source.value.fetch_submodules
      }
      insecure_ssl        = source.value.insecure_ssl
      location            = source.value.location
      report_build_status = source.value.report_build_status
    }

  }
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  description    = var.description
  encryption_key = var.encryption_key
  service_role   = var.service_role
  source_version = var.source_version

  dynamic "vpc_config" {
    for_each = var.vpc_config
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnets            = vpc_config.value.subnets
      vpc_id             = vpc_config.value.vpc_id
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${each.value}-codebuild_project"
  }
}