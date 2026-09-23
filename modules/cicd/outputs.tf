output "aws_codebuild_project_id" {
  description = "Map of CodeBuild project name to project ID."
  value       = { for codebuild_project in var.codebuild_project : codebuild_project => aws_codebuild_project.this[codebuild_project].id }
}

output "aws_codebuild_project_arn" {
  description = "Map of CodeBuild project name to project ARN."
  value       = { for codebuild_project in var.codebuild_project : codebuild_project => aws_codebuild_project.this[codebuild_project].arn }
}

output "aws_codepipeline_id" {
  description = "Map of CodePipeline name to pipeline ID."
  value       = { for codepipeline_project in var.codepipeline_project : codepipeline_project => aws_codepipeline.this[codepipeline_project].id }
}

output "aws_codepipeline_arn" {
  description = "Map of CodePipeline name to pipeline ARN."
  value       = { for codepipeline_project in var.codepipeline_project : codepipeline_project => aws_codepipeline.this[codepipeline_project].arn }
}

