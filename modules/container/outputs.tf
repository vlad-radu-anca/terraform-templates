output "aws_ecs_task_definition_arn" {
    value = {for family in var.family: family=>aws_ecs_task_definition.this[family].arn}
}

output "aws_ecs_cluster_arn" {
    value = {for ecs_cluster in var.ecs_cluster: ecs_cluster=>aws_ecs_cluster.this[ecs_cluster].arn}
}

output "ecr_repository_url" {
    value = {for ecr_repo in var.ecr_repo: ecr_repo=>aws_ecr_repository.this[ecr_repo].repository_url}
}

