# AWS Network and Content Delivery module

These types of resources are supported:

VPC Network:
* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [NACL](https://www.terraform.io/docs/providers/aws/r/default_network_acl.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [Public Subnets](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Private Subnets](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Elastic IP's](https://www.terraform.io/docs/providers/aws/r/eip.html)
* [Nat Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [Public Route Table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Private Route Table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Flow Logs](https://www.terraform.io/docs/providers/aws/r/flow_log.html)

## Terraform versions

Terraform 0.12.26
AWS Provider Version 2.56.0

## Usage

# Prerequistie:
  * If IAM Roles needed for Flow Log to permit to push logs to Cloudwatch --> Initialise Compliance Module and create required IAM Roles and Policies (see the [`iam`](../iam) module)
  * If Cloud Watch Log Group Needed to push logs to cloudwatch log group desstination--> Initialise Monitoring Module and create required Cloud watch log group
  

``` hcl

module "network" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/vpc?ref=main"
  create_vpc  = true
  create_flow_logs = true
  iam_role_arn = module.compliance.iam_role_arn["${name of the IAM Role}"] #Also need to initialize compliance module
  log_destination = module.monitoring.cloudwatch_logging_arn["${name of the Cloud Watch Group}"]   #Also need to initialize monitoring module
  environment = "test" 
  project_name = "testing"
}

```

## Scenarios

* By default creation of VPC and Flow logs disabled
    `enable create_vpc = false and create_flow_logs = false`

* Default Behaviour if create_vpc and create_flow_logs are true
    ``` hcl
    Single VPC
    Single NACL with Default Allow all Ingrress and Egress Rule
    Single Default Security Group
    Single Internet Gateway
    Multiple Public Subnet, count depends on AZ's 
    Multiple Private Subnet, count depends on AZ's
    Single EIP for Nat gateway
    Single NatGateway
    Single Public and Private Route Table, with private subnets mapped to Private Route Table
    VPC level Flow log with log destination to Cloudwatch Group
    ```

* Multiple NACL Rules for Default NACL
   * Provide a list of Nacl Rules:
      ``` hcl
      (Default Rule)

      nacl_rules = [{
        protocol   = -1
        rule_no    = 100
        action     = "allow"
        from_port  = 0
        to_port    = 0
      }]
      ```
* Single NAT Gateway across all subnets (default behaviour)
    *  `if  multiple_nats = false`

* One NAT Gateway per subnet 
    * `if   multiple_nats = true`

* Multiple Public and Private Route Rules for route tables
   * Provide a list of Route Rules:
      ``` hcl
      (Default --> IGW route to Public and NGW route to  Private)

      public_route_rules = [{
        cidr_block                  = ""
        gateway_id                  = ""
        vpc_peering_connection_id   = ""
       }]

      private_route_rules = [{
        cidr_block                  = ""
        gateway_id                  = ""
        vpc_peering_connection_id   = ""
      }]
      ```

* Flow Logs supported for VPC/Subntes/ENI
    * `depends on flow_log_type = "VPC"/"Subnet"/"ENI"`

* Flow Logs can be deployed on Cloudwatch/S3
    * `depends on log_destination_type = "S3"/"cloud-watch-logs"`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_vpc | Want to create VPC or not | `bool` | `false` | no |
| vpc\_cidr\_block | Specify CIDR Range for VPC Network | `string` | `"10.0.0.0/16"` | no |
| instance\_tenancy | A tenancy option for instances launched into the VPC | `string` | `null` | no |
| enable\_dns\_support | A boolean flag to enable/disable DNS support in the VPC | `bool` | `true` | no |
| enable\_dns\_hostnames | A boolean flag to enable/disable DNS hostnames in the VPC | `bool` | `true` | no |
| nacl\_rules | Network ACL Rules | `list(object({}))` | <pre>[<br>  {<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "action": "allow",<br>    "from_port": 0,<br>    "to_port": 0,<br>    <br>  }<br>]</pre> | no |
| newbits | The number of additional subnets bits with which to extend the prefix | `number` | 8 | no |
| multiple\_nats | Want Nats per AZ | `bool` | `false` | no |
| public\_route\_rules | Public Route Table Rules | `list(object({}))` | `null` | no |
| private\_route\_rules | Private Route Table Rules | `list(object({}))` | `null` | no |
| create\_flow\_logs | Want to create Flow Logs | `bool` | `false` | no |
| traffic\_type | The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL | `string` | `"ALL"` | no |
| iam\_role\_arn | The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group | `string` | `null` | no |
| log\_destination\_type | The type of the logging destination. Valid values: cloud-watch-logs, s3. | `string` | `"cloud-watch-logs"` | no |
| log\_destination | The ARN of of the logging destination. If Cloudwatch Selected in destination type | `string` | `null` | no |
| max\_aggregation\_interval |The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. | `number` | `60` | no |
| flow\_log\_type | Flow logs need to enabled for what? Valid values::VPC,Subnet,ENI | `string` | `"VPC"` | no |
| eni\_id | If Flow Log Type is ENI, please specify particular ENI ID | `string` | `null` | no |
| subnet\_id | If Flow Log Type is Subnet, please specify particular Subnet ID | `string` | `null` | no |
