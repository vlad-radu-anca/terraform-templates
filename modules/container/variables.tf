variable "ecr_repo" {
  description = "Name of the repository"
  type        = list(string)
  default     = []
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
}

variable "encryption_configuration" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS. Defaults to AES256."
  type = list(object({
    encryption_type = string
    kms_key         = string
  }))
  default = null
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)"
  type        = bool
  default     = false
}

variable "ecr_lifecycle_policy_repo_name" {
  description = "Specify ecr repo name for which you want lifecycle policy, and create a json policy @ roles_and_policies folder"
  type        = list(string)
  default     = []
}

variable "ecr_repository_policy_repo_name" {
  description = "Specify ecr repo name for which you want repository policy, and create a json policy @ roles_and_policies fodler"
  type        = list(string)
  default     = []
}

variable "ecs_cluster" {
  description = "The name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = list(string)
  default     = []
}

variable "cluster_capacity_providers" {
  description = "Capacity providers to associate with every cluster in `ecs_cluster` (e.g. [\"FARGATE\", \"FARGATE_SPOT\"]). Empty list skips the association."
  type        = list(string)
  default     = []
}

variable "cluster_default_capacity_provider_strategy" {
  description = "Default capacity provider strategy applied to the clusters. Each entry: capacity_provider (string), weight (number), base (number, only one entry may set it)."
  type = list(object({
    capacity_provider = string
    weight            = optional(number)
    base              = optional(number)
  }))
  default = []
}

variable "setting" {
  description = "Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster. "
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "service_name" {
  description = "List of ECS Service names"
  type        = list(string)
  default     = []
}
variable "task_definition_arn" {
  description = "List of Task Definition ARN corressponding to list of service names"
  type        = list(string)
  default     = []
}

variable "cluster" {
  description = "ARN of an ECS cluster"
  type        = string
  default     = null
}

variable "deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks.Not valid when using the DAEMON scheduling strategy."
  type        = string
  default     = null
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks."
  type        = string
  default     = null
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
  type        = bool
  default     = null
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service."
  type        = bool
  default     = null
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown.Only valid for services configured to use load balancers."
  type        = number
  default     = null
}

variable "iam_role" {
  description = "ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the awsvpc network mode. If using awsvpc network mode, do not specify this role."
  type        = string
  default     = null
}

variable "launch_type" {
  description = "The launch type on which to run your service. The valid values are EC2 and FARGATE"
  type        = string
  default     = "EC2"
}

variable "platform_version" {
  description = "The platform version on which to run your service. Only applicable for launch_type set to FARGATE"
  type        = string
  default     = null
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON"
  type        = string
  default     = null
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running.Not valid when using the DAEMON scheduling strategy."
  type        = string
  default     = 1
}

variable "load_balancer" {
  description = <<-EOT
  target_group_arn : (Required for ALB/NLB) The ARN of the Load Balancer target group to associate with the service.
  container_name : (Required) The name of the container to associate with the load balancer (as it appears in a container definition).
  container_port : (Required) The port on the container to associate with the load balancer.
  EOT
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "network_configuration" {
  description = <<-EOT
  subnets : (Required for ALB/NLB) The subnets associated with the task or service.
  security_groups : The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used.
  assign_public_ip : Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false.
  EOT
  type = list(object({
    subnets          = set(string)
    security_groups  = set(string)
    assign_public_ip = bool
  }))
  default = []
}

variable "service_registries" {
  description = <<-EOT
  registry_arn : (The ARN of the Service Registry. The currently supported service registry is Amazon Route 53 Auto Naming Service(aws_service_discovery_service).
  port : The port value used if your Service Discovery service specified an SRV record.
  container_port : The port value, already specified in the task definition, to be used for your service discovery service.
  container_name : The container name value, already specified in the task definition, to be used for your service discovery service.
  EOT
  type = list(object({
    registry_arn   = string
    port           = number
    container_port = number
    container_name = string
  }))
  default = []
}

variable "capacity_provider_strategy" {
  description = <<-EOT
  capacity_provider : The short name of the capacity provider.
  weight : The relative percentage of the total number of launched tasks that should use the specified capacity provider.
  base : The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.
  EOT
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = []
}

variable "deployment_controller_type" {
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS. Default: ECS."
  type        = string
  default     = "ECS"
}

#Container Definition JSON Template variable:
variable "container_name" {
  description = "Name of ECS Service Container"
  type        = string
  default     = ""
}

variable "container_image" {
  description = "Repository URL for Priavte registory or Public Docker image Name"
  type        = string
  default     = ""
}

variable "container_mem_hard_limit" {
  description = "The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed."
  type        = number
  default     = 200
}

variable "container_mem_soft_limit" {
  description = "The soft limit (in MiB) of memory to reserve for the container."
  type        = number
  default     = 200
}

variable "port_mappings" {
  description = "Port mappings allow containers to access ports on the host container instance to send or receive traffic."
  type        = any
  default = [
    {
      "containerPort" : 123,
      "hostPort" : 123,
      "protocol" : "tcp"
    }
  ]
}

variable "essential" {
  description = "If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped. If the essential parameter of a container is marked as false, then its failure does not affect the rest of the containers in a task. If this parameter is omitted, a container is assumed to be essential."
  type        = bool
  default     = true
}

variable "start_timeout" {
  description = "Time duration (in seconds) to wait before giving up on resolving dependencies for a container."
  type        = number
  default     = null
}

variable "stop_timeout" {
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own."
  type        = number
  default     = null
}

variable "health_check" {
  description = "The container health check command and associated configuration parameters for the container."
  type        = any
  default     = null
}

variable "disable_networking" {
  description = "When this parameter is true, networking is disabled within the container."
  type        = bool
  default     = false
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)."
  type        = bool
  default     = false
}

variable "readonly_root_filesystem" {
  description = "When this parameter is true, the container is given read-only access to its root file system."
  type        = bool
  default     = true
}

variable "container_reserved_cpu" {
  description = "The number of cpu units the Amazon ECS container agent will reserve for the container."
  type        = number
  default     = 0
}

variable "container_entry_point" {
  description = "The entry point that is passed to the container."
  type        = any
  default     = null
}

variable "container_command" {
  description = "The command that is passed to the container."
  type        = any
  default     = null
}

variable "container_working_directory" {
  description = "The working directory in which to run commands inside the container."
  type        = string
  default     = null
}

variable "container_env_vars" {
  description = "The environment variables to pass to a container."
  type        = any
  default     = null
}

variable "container_secrets" {
  description = "The environment variables to pass to a container."
  type        = any
  default     = null
}

variable "links" {
  description = "The link parameter allows containers to communicate with each other without the need for port mappings."
  type        = any
  default     = null
}

variable "container_hostname" {
  description = "The hostname to use for your container"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "A list of DNS servers that are presented to the container."
  type        = any
  default     = null
}

variable "dns_search_domains" {
  description = "A list of DNS search domains that are presented to the container"
  type        = any
  default     = null
}

variable "extra_hosts" {
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container."
  type        = any
  default     = null
}

variable "mount_points" {
  description = "The mount points for data volumes in your container."
  type        = any
  default     = null
}

variable "volumes_from" {
  description = "Data volumes to mount from another container."
  type        = any
  default     = null
}

variable "log_configuration" {
  description = "The log configuration specification for the container."
  type        = any
  default     = null
}

variable "container_depends_on" {
  description = "The dependencies defined for container startup and shutdown. A container can contain multiple dependencies."
  type        = any
  default     = null
}

variable "user" {
  description = "The user name to use inside the container."
  type        = string
  default     = null
}

variable "family" {
  description = "A unique name for your task definition."
  type        = list(string)
  default     = []
}

variable "requires_compatibilities" {
  description = "A set of launch types required by the task. The valid values are EC2 and FARGATE."
  type        = set(string)
  default     = ["EC2"]
}

variable "task_role_arn" {
  description = "The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "The Amazon Resource Name (ARN) of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
  default     = null
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
  type        = string
  default     = null
}

variable "cpu" {
  description = "The number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = 256
}

variable "memory" {
  description = "The amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
  type        = number
  default     = 512
}

variable "volume" {
  description = <<-EOT
  name : The name of the volume. This name is referenced in the sourceVolume parameter of container definition in the mountPoints section.
  host_path : The path on the host container instance that is presented to the container. If not set, ECS will create a nonpersistent data volume that starts empty and is deleted after the task has finished.
  scope : The scope for the Docker volume, which determines its lifecycle, either task or shared
  autoprovision :  If this value is true, the Docker volume is created if it does not already exist. Note: This field is only used if the scope is shared.
  driver : The Docker volume driver to use. The driver value must match the driver name provided by Docker because it is used for task placement.
  driver_ports : A map of Docker driver specific options.
  labels : A map of custom metadata to add to your Docker volume.
  file_system_id : The ID of the EFS File System.
  root_directory : The path to mount on the host  
  EOT
  type = list(object({
    name      = string
    host_path = string
    docker_volume_configuration = list(object({
      scope         = string
      autoprovision = string
      driver        = string
      driver_opts   = string
      labels        = string
    }))
    efs_volume_configuration = list(object({
      file_system_id = string
      root_directory = string
    }))
  }))
  default = []
}

variable "ecr_lifecycle_policy_file" {
  description = "File path for ECR  Life Cycle Policy"
  type        = string
  default     = null
}

variable "ecr_repository_policy_file" {
  description = "File path for ECR Repository Policy"
  type        = string
  default     = null
}

variable "environment" {
  type        = string
  description = "Name of the Environment (to be used as Prefix in naming resources)"
  default     = "testing"
}

variable "project_name" {
  type        = string
  description = "Name of the Application/Project (to be used as Prefix in naming resources)"
  default     = "asgard-infra-templates"
}

