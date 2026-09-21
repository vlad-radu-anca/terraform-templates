# AWS Container Module

These types of resources are supported:

* [ECS  Cluster](https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html)
* [ECS  Service](https://www.terraform.io/docs/providers/aws/r/ecs_service.html)
* [ECS  Task Definition](https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html)
* [ECR Repository](https://www.terraform.io/docs/providers/aws/r/ecr_repository.html)

## Terraform versions

Terraform 0.12.26
AWS Provider Version 2.56.0

### Prerequistie:
  * If IAM Roles needed for Task Execution --> Initialise Compliance Module and create required IAM Roles and Policies (see the [`iam`](../iam) module)
  * If Subnets and Security Groups Needed for ECS Service Network Configuration --> use the [`vpc`](../vpc) module to create the network

## Usage

* EC2 Cluster
  ``` hcl
  module "ecs" {
    source = "./modules/container" 
    #ECR Repo and Cluster  
    ecr_repo                            = ["asgard-test-repo"]
    ecs_cluster                         = ["asgard-test-cluster"]

    #ECS Task Definition Configuration
    container_name                      = "asgard-test"
    container_image                     = module.ecs.ecr_repository_url["asgard-test-repo"]
    family                              = "asgard-test-task-defintion"
    requires_compatibilities            = ["EC2"]
    network_mode                        = "bridge"

    #ECS Services Configuration
    service_name = ["asgard-test-service"]
    task_definition_arn = [module.ecs.aws_ecs_task_definition_arn]
    cluster                             = module.ecs.aws_ecs_cluster_arn["asgard-test-cluster"]
    launch_type                         = "EC2"

    environment = "test"
    project_name = "testing"
  }

  ```
* Farget Cluster
  ``` hcl
  To Create Cluster:
    Single ECS Fargate Cluster with One ECS Service running a single task definition with one container having an image from ecr repo

  module "ecs" {
    source                              = "./modules/container"

    #ECR Repo and Cluster  
    ecr_repo                            = ["asgard-test-repo"]
    ecs_cluster                         = ["asgard-test-cluster"]

    #ECS Task Definition Configuration
    #format : module.ecs.ecr_repository_url[${var.ecr_repo}]
    container_image                     = module.ecs.ecr_repository_url["asgard-test-repo"] 
    container_name                      = "asgard-test"
    #format : module.compliance.iam_role_arn[${var.iam_roles_policy_name}]
    execution_role_arn                  = module.compliance.iam_role_arn["ecs_task_execution"] #Also need to initialize compliance module
    family                              = "asgard-test-task-defintion"
    requires_compatibilities            = ["FARGATE"]
    network_mode                        = "awsvpc"

    #ECS Services Configuration
    service_name = ["asgard-test-service"]
    task_definition_arn = [module.ecs.aws_ecs_task_definition_arn]
    #format : module.ecs.aws_ecs_cluster_arn[${var.ecs_cluster}]
    cluster                             = module.ecs.aws_ecs_cluster_arn["asgard-test-cluster"]
    launch_type                         = "FARGATE"
    network_configuration               = [{
      subnets          = module.network.public_subnet_ids
      security_groups  = module.network.vpc_default_sg
      assign_public_ip = false
    }]

    environment = "test"
    project_name = "testing"

  }
  ```
## Scenarios

### ECS Cluster, ECR Repo and ECS Service are configured as an list, if list is empty, no resources will be created.
  * Single Cluster Setup with One ECS Service and One Task Definition all together
      `As show above in Usage`

  * Multiple Empty ECS Cluster:
      ``` hcl 
      will create 3 cluster with names 'ecs_one`, `ecs_two` and `ecs_threee` if, 
      ecs_cluster = ["ecs_one", "ecs_two", "ecs_three"] 
      ```

  * Multiple ECR Repo with default settings:
      ``` hcl 
      will create 3 ecr repo with names `ecr_repo_one`, `ecr_repo_two` and `ecr_repo_three` if, 
      ecr_repo = ["ecr_repo_one", "ecr_repo_two", "ecr_repo_three"] 
      ```

  * Single Task Defintion:
      ``` hcl
      module "ecs" {
        container_image                     = "ecr repository url with tag" 
        container_name                      = "asgard-test"
        execution_role_arn                  = "arn of iam which allows ecs to call other aws services"
        family                              = "asgard-test-task-defintion"
        requires_compatibilities            = ["FARGATE"]
        network_mode                        = "awsvpc"
        environment = "test"
        project_name = "testing"
      }
      ```

  * Single ECS Service:
      ``` hcl
      module "ecs" {
        source                              = "./modules/container"
        service_name = ["asgard-test-service"]
        task_definition_arn = ["arn of task defintion or family with revision"]
        cluster                             = "arn of a ecs cluster"
        launch_type                         = "FARGATE"
        network_configuration               = [{
          subnets          = "list of subnets for ecs container if awsvpc network mode"
          security_groups  = "list of security groups for ecs container if awsvpc network mode"
          assign_public_ip = false
        }]
        environment = "test"
        project_name = "testing"
      }
      ```


## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| ecr_repo | Name of the repository | `list(string)` | `[]` |
| image_tag_mutability | The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE | `string` | `"MUTABLE"` |
| scan_on_push | Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false) | `bool` | `false` |
| ecr_lifecycle_policy_repo_name | Specify ecr repo name for which you want lifecycle policy, and create a json policy @ roles_and_policies folder | `list(string)` | `[]` |
| ecr_repository_policy_repo_name | Specify ecr repo name for which you want repository policy, and create a json policy @ roles_and_policies fodler | `list(string)` | `[]` |
| ecs_cluster | The name of the cluster (up to 255 letters, numbers, hyphens, and underscores) | `list(string)` | `[]` |
| setting | Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster. | `list(object({}))` | <pre>[<br>  {<br>    "name": "",<br>    "value": "",<br>  <br>  }<br>]</pre> |
| service_name | Provide list of ECS Service names | `list(string)` | `"test-service"` |
| task_definition_arn | List of Task Definition ARN corressponding to list of service names |  `list(string)` | `"task definition arn"` |
| cluster | ARN of an ECS cluster | `string` | `null` |
| deployment_maximum_percent | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks.Not valid when using the DAEMON scheduling strategy. | `string` | `null` |
| deployment_minimum_healthy_percent | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks. | `string` | `null` |
| enable_ecs_managed_tags | Specifies whether to enable Amazon ECS managed tags for the tasks within the service. | `bool` | `null` |
| force_new_deployment | Enable to force a new task deployment of the service. | `bool` | `null` |
| health_check_grace_period_seconds | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown.Only valid for services configured to use load balancers. | `number` | `null` |
| iam_role | ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the awsvpc network mode. If using awsvpc network mode, do not specify this role. | `string` | `null` |
| launch_type | The launch type on which to run your service. The valid values are EC2 and FARGATE | `string` | `"EC2"` |
| platform_version | The platform version on which to run your service. Only applicable for launch_type set to FARGATE | `string` | `null` |
| scheduling_strategy | The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON | `string` | `null` |
| desired_count | The number of instances of the task definition to place and keep running.Not valid when using the DAEMON scheduling strategy. | `string` | `1` |
| load_balancer | Load Balancer Mapping Configuration to ECS Service | `list(object({}))` | <pre>[<br>  {<br>    "target_group_arn": "",<br>    "container_name": "",<br>    "container_port":  ,<br>  	<br>  }<br>]</pre> |
| network_configuration | Network Configuration to map subnets and security groups to container | `list(object({}))` | <pre>[<br>  {<br>    "subnets": [""],<br>    "security_groups": [""],<br>    "assign_public_ip": ,<br>  	<br>  }<br>]</pre> |
| service_registries | Configuration to Map container IP's and Ports to Route 53/CloudMap DNS | `list(object({}))` | <pre>[<br>  {<br>    "registry_arn": "",<br>    "port": ,<br>    "container_port": ,<br>    "container_name": "",<br>  	<br>  }<br>]</pre> |
| capacity_provider_strategy | | `list(object({}))` | <pre>[<br>  {<br>    "capacity_provider": "",<br>    "weight": ,<br>    "base": ,<br>  	<br>  }<br>]</pre> |
| deployment_controller_type | Type of deployment controller. Valid values: CODE_DEPLOY, ECS. Default: ECS. | `string` | `"ECS"` |
| container_name | Name of ECS Service Container | `string` | `""` |
| container_image | Repository URL for Priavte registory or Public Docker image Name | `string` | `""` |
| container_mem_hard_limit | The amount (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed. | `number` | `200` |
| container_mem_soft_limit | The soft limit (in MiB) of memory to reserve for the container. | `number` | `200` |
| port_mappings | Port mappings allow containers to access ports on the host container instance to send or receive traffic. | `any` | <pre>{<br>    "containerPort": 123,<br>    "hostPort": 123,<br>    "protocol": "tcp",<br>  	<br>  }<br>]</pre> |
| essential | If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped. If the essential parameter of a container is marked as false, then its failure does not affect the rest of the containers in a task. If this parameter is omitted, a container is assumed to be essential. | `bool` | `true` |
| startTimeout | Time duration (in seconds) to wait before giving up on resolving dependencies for a container. `number` | `null` |
| stopTimeout | Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own. | `stopTimeout` | `null` |
| health_check | The container health check command and associated configuration parameters for the container. | `any` | <pre>{<br>  {<br>    "command": [""],<br>    "interval": ,<br>    "timeout": ,<br>    "retries": ,<br>    "startPeriod": ,<br>  	<br>  }<br>]</pre> |
| disableNetworking | When this parameter is true, networking is disabled within the container. | `bool` | `false` |
| privileged | When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user). | `bool` | `false` |
| readonlyRootFilesystem | When this parameter is true, the container is given read-only access to its root file system. | `bool` | `true` |
| container_reserved_cpu | The number of cpu units the Amazon ECS container agent will reserve for the container. | `number` | `0` |
| container_entry_point | The entry point that is passed to the container. | `any` | `null` |
| container_command | The command that is passed to the container. | `any` | `null` |
| container_working_directory | The working directory in which to run commands inside the container. | `string` | `null` |
| container_env_vars | The environment variables to pass to a container. | `any` | <pre>{<br>  {<br>    "name": "",<br>    "value": "",<br>    <br>  }<br>]</pre> |
| links | The link parameter allows containers to communicate with each other without the need for port mappings. | `any` | `[""]` |
| container_hostname | The hostname to use for your container. | `string` | `null` |
| dns_servers | A list of DNS servers that are presented to the container. | `any` | `[""]` |
| dns_search_domains | A list of DNS search domains that are presented to the container. | `any` |  `[""]` |
| extra_hosts | A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. | `any` | <pre>{<br>  {<br>    "hostname": "",<br>    "ipAddress": "",<br>    <br>  }<br>]</pre> |
| mount_points	 | The mount points for data volumes in your container. | `any` | <pre>{<br>  {<br>    "sourceVolume": "",<br>    "containerPath": "",<br>    "readOnly": true,<br>    <br>  }<br>]</pre> |
| volumes_from | Data volumes to mount from another container. | `any` | <pre>{<br>  {<br>    "sourceContainer": "",<br>    "readOnly": true,<br>    <br>  }<br>]</pre> |
| log_configuration | The log configuration specification for the container. | `any` | `null` |
| container_depends_on | The dependencies defined for container startup and shutdown. A container can contain multiple dependencies. |  `any` | <pre>{<br>  {<br>    "containerName": "",<br>    "condition": "HEALTHY",<br>    <br>  }<br>]</pre> |
| user | The user name to use inside the container. | `string` | `null` |
| family | A unique name for your task definition. | `string` | `null` |
| requires_compatibilities | A set of launch types required by the task. The valid values are EC2 and FARGATE. | `set(string)` | `["EC2"]` |
| task_role_arn | The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. | `string` | `null` |
| execution_role_arn | The Amazon Resource Name (ARN) of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | `null` |
| network_mode | The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host. | `string` | `null` |
| cpu | The number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required. | `number` | `256` |
| memory | The amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required. | `number` | `512` |
| volume | Volume Configuration for mapping containers to host volumes | `` | <pre>[<br>  {<br>    "name": "",<br>    "host_path": "",<br>    "docker_volume_configuration": [<br>      {<br>        "scope": "",<br>        "autoprovision": "",<br>        "driver": "",<br>        "driver_opts": "",<br>        "labels": "",<br><br>}<br>]</pre>            "efs_volume_configuration":[<br>  {<br>    "file_system_id": "",<br>    "root_directory": "",<br>    <br>  }<br>]</pre>    <br>  }<br>]</pre>
 |


