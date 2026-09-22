# AWS Aurora module

Amazon Aurora clusters for **PostgreSQL** and **MySQL**, provisioned or **Serverless v2**.

- Master password generated and rotated by RDS in **Secrets Manager** (`manage_master_user_password`, on by default).
- **Serverless v2** scaling, including scale-to-zero with `min_capacity = 0` and `seconds_until_auto_pause`.
- Cluster instances declared as a map, so a cluster can have a writer and any number of readers. Adding or removing one reader never touches the others.
- Subnet group, security group and parameter groups are created and wired by the module. Existing ones can be supplied instead.
- Storage encrypted at rest, optional **I/O-Optimized** storage (`aurora-iopt1`).
- **Performance Insights** and **Enhanced Monitoring** enabled by default, including the monitoring IAM role.
- Engine-appropriate **CloudWatch log exports**, backtracking (Aurora MySQL), global clusters, RDS Data API and IAM database authentication as options.

For a single-instance RDS database use [`modules/rds`](../rds).

## Usage

```hcl
module "aurora" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/database?ref=v1.0.0"

  project_name = "demo"
  environment  = "prod"

  engine         = "aurora-postgresql"
  engine_version = "16.4"
  database_name  = "app"

  instance_class = "db.r6g.large"
  instances = {
    writer   = { promotion_tier = 0 }
    reader-1 = { promotion_tier = 1 }
  }

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.app.id]

  deletion_protection = true
  skip_final_snapshot = false
}
```

Serverless v2 instead of fixed instance classes:

```hcl
  serverlessv2_scaling = {
    min_capacity             = 0   # scale to zero when idle
    max_capacity             = 16
    seconds_until_auto_pause = 900
  }
```

A runnable example with both cluster types is in [`examples/complete`](examples/complete).

## Design notes

- Port and log exports are derived from `engine`. Override them only when you need to.
- Setting `serverlessv2_scaling` forces every instance to `db.serverless` and ignores `instance_class`, because Aurora requires that class for Serverless v2.
- `engine_mode` stays `provisioned` for Serverless v2 clusters. The `serverless` mode is Aurora Serverless v1 and is legacy.
- Scale-to-zero requires `min_capacity = 0`. The cluster resumes on the next connection, which adds latency to that request.
- `final_snapshot_identifier` embeds a timestamp and is protected with `ignore_changes`, so it does not cause a perpetual diff.
- Supplying `vpc_security_group_ids` disables creation of the module's own security group, and `allowed_cidr_blocks` / `allowed_security_group_ids` are then ignored.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
