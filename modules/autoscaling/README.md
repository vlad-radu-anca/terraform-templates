# AWS Application AutoScaling  Module

[User Guide](https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html)

Supported scaling:

* [Target tracking scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-target-tracking.html)

## Terraform versions

Terraform 0.13.6
AWS Provider Version 3.27.0


## Usage

* ECS Service Autoscaling
  ``` hcl
  module "ecs_autocaling" {
    source                              = "./modules/autoscaling"
    resource_id = "service/<cluster_name>/service_name"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
    autoscaling_policy_vars = {
                        "memory_utilization" = {
                            "policy_type": "TargetTrackingScaling",
                            "predefined_metric_type": "ECSServiceAverageMemoryUtilization",
                            "target_value" = 80
                        },
                      "cpu_utilizaion" = {
                            "policy_type": "TargetTrackingScaling",
                            "predefined_metric_type": "ECSServiceAverageCPUUtilization",
                            "target_value" = 60
                        }
                    }
    max_capacity = 2
    min_capacity = 2
  }

  ```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| max_capcity | The max capacity of the scalable target | `string` |  |
| min _capcity | The min  capacity of the scalable target | `string` |  |
| resource_id | The resource type and unique identifier string for the resource associated with the scaling policy | `string` |  |
| scalable_dimension | The scalable dimension of the scalable targe | `string` |  |
| service_namespace | The AWS service namespace of the scalable target | `string` |  |
| autoscaling_policy_vars | The variables for Autoscaling policies | `map(object({}))` | }|


## Autoscaling Policy Vars
Sample value for ECS autoscaling_policy_vars
```
{
  "memory_utilization" = {
      "policy_type": "TargetTrackingScaling",
      "predefined_metric_type": "ECSServiceAverageMemoryUtilization",
      "target_value" = 80
  },
"cpu_utilizaion" = {
      "policy_type": "TargetTrackingScaling",
      "predefined_metric_type": "ECSServiceAverageCPUUtilization",
      "target_value" = 60
  }
}
```

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name |  The name of the policy.(Key of autoscaling_policy_vars will be used as name of policy )| `string` |  |
| policy_type | The policy type. Valid value is TargetTrackingScaling | `string` |  |
| predefined_metric_type | A predefined metric | `string` |  |
| target_value | The target value for the metric | `number` |  |