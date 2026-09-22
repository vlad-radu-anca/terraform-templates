# AWS S3 module

A single S3 bucket with its configuration split across the dedicated `aws_s3_bucket_*` resources, which is how the AWS provider has expected buckets to be defined since version 4.

Secure by default:

- All four **public access blocks** on (`block_public_access`), to be turned off only for a deliberately public bucket such as a website origin.
- **Encryption** always configured: SSE-S3 by default, SSE-KMS when `kms_key_id` is set, with an S3 bucket key to cut KMS request costs.
- **`BucketOwnerEnforced` ownership** by default, which disables ACLs entirely. ACLs are only wired up if you opt out of that.
- The bucket policy is applied after the public access block, so a policy cannot briefly expose the bucket during apply.

Optional: versioning with MFA delete, lifecycle rules (transitions, expiry, noncurrent versions, delete markers, incomplete multipart uploads), server access logging, CORS, static website hosting and transfer acceleration.

## Usage

```hcl
module "data" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/s3?ref=v1.0.0"

  project_name = "demo"
  environment  = "prod"
  bucket_name  = "demo-prod-data"

  kms_key_id         = aws_kms_key.s3.arn
  versioning_enabled = true

  lifecycle_rules = {
    tier-and-expire = {
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER_IR" },
      ]
      noncurrent_version_expiration_days = 365
      expire_delete_markers              = true
    }
  }
}
```

A runnable example with a data bucket, a log target and a public website bucket is in [`examples/complete`](examples/complete).

## Design notes

- One bucket per module instance. Use `for_each` at the call site for several buckets, rather than passing a list, so that removing one bucket never disturbs the others.
- `lifecycle_rules` is keyed by rule ID. Each rule gets a `filter`, which the provider requires even when the filter is empty.
- Lifecycle rules depend on the versioning resource, because rules that act on noncurrent versions are rejected on a bucket where versioning has not been configured yet.
- Setting `logging` requires the target bucket to allow writes from the S3 log delivery group. The example shows a log bucket using `BucketOwnerPreferred` with the `log-delivery-write` canned ACL, which is the one case where ACLs are still needed.
- `versioning_enabled = null` (the default) leaves versioning untouched rather than actively suspending it, so the module can be adopted on an existing bucket without changing its versioning state.

## Migrating from the previous version

This module used to create several buckets from `s3_bucket_name` and configure them with inline arguments on `aws_s3_bucket`. Those arguments have been deprecated since AWS provider v4, and four of the features (`versioning`, `logging`, `cors`, `website`) were routed through the `list()` function, which Terraform removed in v0.15. Any caller that set one of them got `Call to function "list" failed` at plan time, while `terraform validate` still reported success because the variables default to null.

The inputs are therefore renamed rather than kept compatible:

| Before | Now |
| --- | --- |
| `s3_bucket_name = ["a", "b"]` | `bucket_name = "a"`, with `for_each` at the call site |
| `s3_versioning = { enabled = true }` | `versioning_enabled = true` |
| `s3_logging` | `logging` |
| `s3_cors_vars` | `cors_rules` |
| `s3_static_website_vars` | `website` |
| `s3_lifecycle_rule_vars` (list) | `lifecycle_rules` (map keyed by rule ID) |
| `s3_policy_document` | `policy` |
| `s3_acl`, `s3_grant_acl_vars` | `acl`, plus `object_ownership` |
| `s3_force_destroy` | `force_destroy` |

Existing buckets keep working: the new resources adopt the bucket's current settings on the next apply, but review the plan, because encryption and public access blocks are now managed explicitly.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
