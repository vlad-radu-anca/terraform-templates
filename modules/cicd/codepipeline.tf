resource "aws_codepipeline" "this" {
  for_each = toset(var.codepipeline_project)
  name     = each.value
  role_arn = var.role_arn
  dynamic "artifact_store" {
    for_each = var.artifact_store
    content {
      location = artifact_store.value.location
      type     = artifact_store.value.type
      dynamic "encryption_key" {
        for_each = artifact_store.value.encryption_key
        content {
          id   = encryption_key.value.id
          type = encryption_key.value.type
        }

      }
      region = artifact_store.value.region
    }
  }
  dynamic "stage" {
    for_each = var.stage
    content {
      name = stage.value.name
      dynamic "action" {
        for_each = stage.value.action
        content {
          category         = action.value.category
          owner            = action.value.owner
          name             = action.value.name
          provider         = action.value.provider
          version          = action.value.version
          configuration    = action.value.configuration
          input_artifacts  = action.value.input_artifacts
          output_artifacts = action.value.output_artifacts
          role_arn         = action.value.role_arn
          run_order        = action.value.run_order
          region           = action.value.region
          namespace        = action.value.namespace
        }
      }
    }
  }
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${each.value}-codepipeline_project"
  }

}

