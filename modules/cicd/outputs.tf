output "aws_codebuild_project_id" {
  value = { for codebuild_project in var.codebuild_project : codebuild_project => aws_codebuild_project.this[codebuild_project].id }
}

output "aws_codebuild_project_arn" {
  value = { for codebuild_project in var.codebuild_project : codebuild_project => aws_codebuild_project.this[codebuild_project].arn }
}

output "aws_codepipeline_id" {
  value = { for codepipeline_project in var.codepipeline_project : codepipeline_project => aws_codepipeline.this[codepipeline_project].id }
}

output "aws_codepipeline_arn" {
  value = { for codepipeline_project in var.codepipeline_project : codepipeline_project => aws_codepipeline.this[codepipeline_project].arn }
}

