# terraform-templates

A library of reusable Terraform modules for AWS, covering networking, compute, containers, Kubernetes, databases, edge and CI/CD.

The modules were originally written in 2021 for Terraform 0.13 and AWS provider v3, and used to run real workloads. This repository is the ongoing effort to bring them to current Terraform and AWS provider v6, add the tooling a module library needs (pinning, linting, security scanning, examples, docs), and extend the catalogue. The commit history is intentionally kept readable: one focused change per PR, so the migration itself is visible.

[![CI](https://github.com/vlad-radu-anca/terraform-templates/actions/workflows/ci.yaml/badge.svg)](https://github.com/vlad-radu-anca/terraform-templates/actions/workflows/ci.yaml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

## Modules

| Module | Resources | Notes |
| --- | --- | --- |
| [`vpc`](modules/vpc) | VPC, subnets per AZ, IGW, NAT (single or per AZ), route tables, NACLs, flow logs | Foundation for every other module |
| [`security_group`](modules/security_group) | Security groups | |
| [`eks`](modules/eks) | EKS cluster, managed node groups, add-ons, access entries, OIDC provider | Access-entry auth, IMDSv2, add-on ordering |
| [`container`](modules/container) | ECR repositories, ECS cluster, capacity providers, services, task definitions | |
| [`compute`](modules/compute) | EC2 instances | |
| [`autoscaling`](modules/autoscaling) | Application Auto Scaling targets and policies | For ECS services |
| [`alb`](modules/alb) | ALB/NLB, listeners, rules, target groups | |
| [`rds`](modules/rds) | RDS instance (PostgreSQL, MySQL, MariaDB), parameter/option groups, security group, replicas | Secrets Manager managed password |
| [`database`](modules/database) | Aurora cluster, instances, parameter groups, security group | Provisioned or Serverless v2, Secrets Manager managed password |
| [`docdb`](modules/docdb) | DocumentDB cluster and instances | |
| [`elasticache`](modules/elasticache) | ElastiCache cluster | |
| [`opensearch`](modules/opensearch) | OpenSearch domain, security group, log groups and log resource policy | Encrypted, HTTPS enforced, VPC placed, FGAC |
| [`s3`](modules/s3) | Bucket, public access block, encryption, versioning, lifecycle, logging, CORS, website, policy | Secure by default |
| [`cdn`](modules/cdn) | CloudFront distribution, origin access control | Cache policies, S3 and custom origins, origin groups |
| [`cloudfront_key_group`](modules/cloudfront_key_group) | CloudFront public keys and key groups | Signed URLs |
| [`waf`](modules/waf) | WAFv2 web ACL and association | |
| [`cognito`](modules/cognito) | Cognito user pool, domain, identity pool | |
| [`lambda`](modules/lambda) | Lambda functions and permissions | |
| [`cicd`](modules/cicd) | CodeBuild, CodePipeline, CodeStar notifications | |
| [`cloudwatch`](modules/cloudwatch) | Log groups, event rules and targets | |
| [`iam`](modules/iam) | IAM roles and inline policies | |
| [`kms`](modules/kms) | KMS keys and aliases | |
| [`parameters`](modules/parameters) | SSM parameters | |

## Usage

Reference a module directly from this repository and pin to a tag:

```hcl
module "vpc" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/vpc?ref=v1.0.0"

  project_name   = "demo"
  environment    = "dev"
  vpc_cidr_block = "10.0.0.0/16"
  newbits        = 8
}

module "eks" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/eks?ref=v1.0.0"

  project_name = "demo"
  environment  = "dev"
  subnet_ids   = module.vpc.private_subnet_ids

  node_groups = {
    general = { instance_types = ["t3.large"], min_size = 2, max_size = 5 }
  }
}
```

Modules that have an `examples/complete` directory contain a runnable configuration that composes with the `vpc` module. These examples are validated in CI.

## Requirements

- Terraform >= 1.5
- AWS provider ~> 6.0

Every module declares these in its `versions.tf`.

## Quality gates

Every pull request runs:

- `terraform fmt -check` across the repository
- `terraform validate` for every module and every example, as a matrix, against the pinned provider
- [tflint](https://github.com/terraform-linters/tflint) with the recommended ruleset and the AWS plugin
- [trivy](https://github.com/aquasecurity/trivy) misconfiguration scan (HIGH and CRITICAL)

The same checks run locally through [pre-commit](.pre-commit-config.yaml):

```sh
brew install tflint trivy pre-commit
pre-commit install
```

## Conventions

- Inputs are typed and documented. Optional object attributes use `optional()` with defaults, so callers only set what they need.
- Collections of resources are keyed maps driven by `for_each`, not lists indexed by `count`, so removing one element never recreates its neighbours. Older modules are being moved to this pattern as they are touched.
- Modules take `project_name` and `environment` and tag the resources they create with `Terraform`, `Environment` and `Project`. The modules rewritten so far (`rds`, `eks`, `database`, `s3`, `opensearch`, `cdn`) also accept a `tags` map that is merged on top; the remaining modules are gaining it as they are reworked.
- Secrets never live in variables with defaults. Where AWS can manage a secret (RDS master password), the module uses that.
- Modules create the IAM roles they need (RDS monitoring, EKS cluster and node roles) but accept an existing role ARN instead.

## Roadmap

Planned after `v1.0.0`:

1. `alb`, `lambda`, `iam`, `parameters` and `security_group` still index parallel lists with `count`. Move them to `for_each` maps, like the modules already reworked.
2. Generated input and output tables with terraform-docs, and a README for every module.
3. An `examples/` directory for the modules that do not have one yet.
4. Reference architectures under a top-level `examples/` directory, composing several modules into a working system.

## License

[Apache-2.0](LICENSE)
