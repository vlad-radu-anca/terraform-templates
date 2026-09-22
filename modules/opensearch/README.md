# AWS OpenSearch module

Amazon OpenSearch Service domain, replacing the previous `es` module and its `aws_elasticsearch_domain` resource.

Secure by default:

- **Encryption at rest** and **node-to-node encryption** on, with an optional customer-managed KMS key.
- **HTTPS enforced** with a modern TLS policy (`Policy-Min-TLS-1-2-PFS-2023-10`).
- **VPC placement** by default when you pass `subnet_ids`, with a module-managed security group that only opens port 443 to the sources you name.
- **Fine-grained access control** using an IAM principal as master user, so no password needs to exist.
- **Log publishing** to CloudWatch, including the log resource policy the service needs. Without that policy a domain comes up with logging silently disabled.

Also supported: dedicated master nodes, UltraWarm, Multi-AZ with standby, zone awareness derived from the subnets you pass, gp3 storage, Auto-Tune, off-peak windows, automatic service software updates and custom endpoints.

## Usage

```hcl
module "opensearch" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/opensearch?ref=v1.0.0"

  project_name   = "demo"
  environment    = "prod"
  engine_version = "OpenSearch_2.17"

  instance_type  = "r6g.large.search"
  instance_count = 2

  dedicated_master = {
    enabled = true
    count   = 3
  }

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = slice(module.vpc.private_subnet_ids, 0, 2)
  allowed_security_group_ids = [aws_security_group.app.id]

  fine_grained_access_control = {
    master_user_arn = aws_iam_role.search_admin.arn
  }
}
```

A runnable example with KMS, dedicated masters, audit logs and a VPC is in [`examples/complete`](examples/complete).

## Design notes

- Zone awareness is derived from `subnet_ids`: pass two or more subnets and it is enabled with a matching availability zone count. This avoids the common mismatch where zone awareness is switched on but the subnet count disagrees.
- Fine-grained access control requires encryption at rest, node-to-node encryption and HTTPS, which are the module defaults, so it works without extra configuration.
- `fine_grained_access_control` is marked sensitive because it can carry a password. Whether it is enabled is not secret, so that single check is unwrapped with `nonsensitive()` to keep it usable in a `for_each`.
- Leaving `subnet_ids` empty creates a public domain, which then depends entirely on `access_policies`. Prefer a VPC domain.
- `engine_version` defaults to null, which lets AWS choose its current default. Pin it for production so a later apply does not move the cluster.

## Migrating from the `es` module

The module was renamed from `es` to `opensearch`, and `aws_elasticsearch_domain` was replaced by `aws_opensearch_domain`. The old module carried 244 lines of commented-out code and exposed eight inputs with no outputs at all, so the interface is new rather than compatible:

| Before (`es`) | Now (`opensearch`) |
| --- | --- |
| `elasticsearch_version` | `engine_version` (e.g. `OpenSearch_2.17`) |
| `ebs_options` map | `ebs` object |
| `cluster_config` map | `instance_type`, `instance_count`, `dedicated_master`, `warm_storage` |
| `vpc_options` map | `subnet_ids`, `security_group_ids` or `allowed_*` |
| no outputs | `endpoint`, `dashboard_endpoint`, `arn`, `domain_id`, and more |

AWS supports in-place upgrades from Elasticsearch to OpenSearch, and `aws_opensearch_domain` can adopt an existing Elasticsearch domain by importing it. Review the plan before applying to an existing domain, because encryption, HTTPS and logging are now managed explicitly.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
