output "aws_ecs_task_definition_arn" {
  description = "Map of task definition family to the ARN of its latest revision."
  value       = { for family in var.family : family => aws_ecs_task_definition.this[family].arn }
}

output "aws_ecs_cluster_arn" {
  description = "Map of ECS cluster name to cluster ARN."
  value       = { for ecs_cluster in var.ecs_cluster : ecs_cluster => aws_ecs_cluster.this[ecs_cluster].arn }
}

output "ecr_repository_url" {
  description = "Map of ECR repository name to its repository URL, used as the image prefix when pushing."
  value       = { for ecr_repo in var.ecr_repo : ecr_repo => aws_ecr_repository.this[ecr_repo].repository_url }
}

