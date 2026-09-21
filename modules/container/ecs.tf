resource "aws_ecs_cluster" "this" {
  for_each = toset(var.ecs_cluster)
  name     = each.value
  dynamic "setting" {
    for_each = var.setting
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }
  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${each.value}-ecs_cluster"
  }
}

# Cluster capacity providers moved out of aws_ecs_cluster in AWS provider v5.
resource "aws_ecs_cluster_capacity_providers" "this" {
  for_each = length(var.cluster_capacity_providers) > 0 ? aws_ecs_cluster.this : {}

  cluster_name       = each.value.name
  capacity_providers = var.cluster_capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.cluster_default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}

resource "aws_ecs_service" "this" {
  count           = length(var.service_name)
  name            = var.service_name[count.index]
  task_definition = var.task_definition_arn[count.index]

  cluster                            = var.cluster
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  //force_new_deployment                  = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  iam_role                          = var.iam_role
  launch_type                       = var.launch_type
  platform_version                  = var.platform_version
  scheduling_strategy               = var.scheduling_strategy
  desired_count                     = var.desired_count

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "network_configuration" {
    for_each = var.network_configuration
    content {
      subnets          = flatten(network_configuration.value.subnets)
      security_groups  = flatten(network_configuration.value.security_groups)
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = service_registries.value.port
      container_port = service_registries.value.container_port
      container_name = service_registries.value.container_name
    }

  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }

  }

  deployment_controller {
    type = var.deployment_controller_type
  }

}


# Container definition built as an HCL object and encoded once. Null attributes are
# dropped so ECS only sees the fields that were actually set.
locals {
  container_definition = {
    name                   = var.container_name
    image                  = var.container_image
    cpu                    = var.container_reserved_cpu
    memory                 = var.container_mem_hard_limit
    memoryReservation      = var.container_mem_soft_limit
    links                  = var.links
    portMappings           = var.port_mappings
    secrets                = var.container_secrets
    essential              = var.essential
    entryPoint             = var.container_entry_point
    command                = var.container_command
    environment            = var.container_env_vars
    mountPoints            = var.mount_points
    volumesFrom            = var.volumes_from
    dependsOn              = var.container_depends_on
    startTimeout           = var.startTimeout
    stopTimeout            = var.stopTimeout
    hostname               = var.container_hostname
    user                   = var.user
    workingDirectory       = var.container_working_directory
    disableNetworking      = var.disableNetworking
    privileged             = var.privileged
    readonlyRootFilesystem = var.readonlyRootFilesystem
    dnsServers             = var.dns_servers
    dnsSearchDomains       = var.dns_search_domains
    extraHosts             = var.extra_hosts
    logConfiguration       = var.log_configuration
    healthCheck            = var.health_check
  }

  container_definitions = jsonencode([
    { for k, v in local.container_definition : k => v if v != null }
  ])
}

resource "aws_ecs_task_definition" "this" {
  for_each                 = toset(var.family)
  family                   = each.value
  container_definitions    = local.container_definitions
  requires_compatibilities = var.requires_compatibilities
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  network_mode             = var.network_mode
  cpu                      = var.cpu
  memory                   = var.memory
  dynamic "volume" {
    for_each = var.volume
    content {
      name      = volume.value.mount_points
      host_path = volume.value.host_path
      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration
        content {
          scope         = docker_volume_configuration.value.scope
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
        }
      }
      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration
        content {
          file_system_id = efs_volume_configuration.value.file_system_id
          root_directory = efs_volume_configuration.value.root_directory
        }
      }
    }
  }

  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${each.value}-ecs_task_definition"
  }
}
