resource "aws_ecr_repository" "this" {
  for_each             = toset(var.ecr_repo)
  name                 = "${each.value}"
  image_tag_mutability = var.image_tag_mutability
  dynamic "encryption_configuration"  {
    for_each           = toset(var.encryption_configuration)
    content{
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key
    }
  }
  image_scanning_configuration {
    scan_on_push       = var.scan_on_push
  }

  tags = {
      Terraform        = true
      Environment      = var.environment
      Name             = "ecr_repo-${each.value}"
  }
}

#Life Cycle for ECR Docker images in Json
resource "aws_ecr_lifecycle_policy" "this" {
  for_each             = toset(var.ecr_lifecycle_policy_repo_name)
  repository           = each.value
  policy               = var.ecr_lifecycle_policy_file
}

#Provides an Elastic Container Registry Repository Policy.
resource "aws_ecr_repository_policy" "this" {
  for_each             = toset(var.ecr_repository_policy_repo_name)
  repository           = each.value
  policy               = var.ecr_repository_policy_file
}
