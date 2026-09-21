# AWS RDS module

Single-instance Amazon RDS for **PostgreSQL**, **MySQL** and **MariaDB** with sensible production defaults:

- Master password generated and rotated by RDS in **Secrets Manager** (`manage_master_user_password`, on by default). No plaintext credentials in state or tfvars.
- Storage encrypted at rest, `gp3` by default, **storage autoscaling** up to `max_allocated_storage`.
- Dedicated **security group** with one ingress rule per CIDR or source security group (`aws_vpc_security_group_*_rule` resources, not inline rules).
- Optional module-managed **parameter group** and **option group** (MySQL/MariaDB only).
- **Performance Insights** and **Enhanced Monitoring** enabled by default, including the monitoring IAM role.
- Engine-appropriate **CloudWatch log exports** (`postgresql`/`upgrade`, or `error`/`general`/`slowquery`).
- Multi-AZ, deletion protection, final snapshot and IAM database authentication as simple toggles.
- Optional **read replicas** via `replica_count`.

For Aurora clusters use [`modules/database`](../database).

## Usage

```hcl
module "postgres" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/rds?ref=v1.0.0"

  project_name = "demo"
  environment  = "prod"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.r6g.large"

  db_name  = "app"
  username = "app_admin"

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]

  multi_az            = true
  deletion_protection = true
  skip_final_snapshot = false

  parameter_group_family = "postgres16"
  parameters = {
    "rds.force_ssl" = { value = "1" }
  }
}

# Read the generated credentials at runtime:
data "aws_secretsmanager_secret_version" "db" {
  secret_id = module.postgres.master_user_secret_arn
}
```

A complete, runnable example with PostgreSQL and MySQL side by side lives in [`examples/complete`](examples/complete).

## Design notes

- Port and log exports are derived from `engine`. Override them only when you need to.
- Security group ingress uses `for_each` over the allowed sources, so adding or removing one source never rebuilds the others.
- Option groups are skipped for PostgreSQL even if `options` is set, because PostgreSQL does not support them.
- `final_snapshot_identifier` embeds a timestamp and is protected with `ignore_changes`, so it does not cause a perpetual diff.
- Replicas inherit engine, storage and credentials from the primary. `backup_retention_period` on the primary must be at least 1 for replicas to be created.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
