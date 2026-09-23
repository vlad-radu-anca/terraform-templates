# AWS CloudFront module

A CloudFront distribution built on the current CloudFront feature set: **cache policies** instead of `forwarded_values`, and **Origin Access Control** instead of the legacy Origin Access Identity.

- **Origins as a map**, each declared as `s3` or `custom`. S3 origins get their own Origin Access Control so the bucket can stay completely private. Custom origins get a protocol config. The two are mutually exclusive, and the module enforces that.
- **Managed policies by name.** Pass `cache_policy_name = "CachingOptimized"` rather than a UUID, and the module resolves it. Same for origin request and response headers policies.
- **Security headers by default** through the `SecurityHeadersPolicy` managed response headers policy.
- **Origin groups** for failover, custom error responses for single page apps, geo restrictions, standard access logging, WAF association, HTTP/3, IPv6 and CloudFront Functions or Lambda@Edge.

## Usage

```hcl
module "cdn" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/cdn?ref=v1.0.0"

  project_name = "demo"
  environment  = "prod"

  default_root_object = "index.html"

  origins = {
    s3-site = {
      domain_name = module.site.bucket_regional_domain_name
      type        = "s3"
    }
    api = {
      domain_name          = aws_lb.this.dns_name
      type                 = "custom"
      custom_origin_config = { origin_protocol_policy = "https-only" }
    }
  }

  default_cache_behavior = {
    target_origin_id  = "s3-site"
    cache_policy_name = "CachingOptimized"
  }

  ordered_cache_behaviors = [{
    path_pattern               = "/api/*"
    target_origin_id           = "api"
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cache_policy_name          = "CachingDisabled"
    origin_request_policy_name = "AllViewerExceptHostHeader"
  }]
}
```

The distribution does not grant itself access to the bucket. Attach a policy to the bucket that allows the `cloudfront.amazonaws.com` service principal when `AWS:SourceArn` matches the distribution ARN. [`examples/complete`](examples/complete) shows that policy alongside an S3 origin, an API origin, an origin group and access logging.

## Design notes

- `type = "s3"` versus `type = "custom"` decides which origin block is emitted. The previous version of this module emitted `s3_origin_config` on every origin, including custom ones, which CloudFront rejects.
- Managed policies are resolved through data sources, so an offline `terraform plan` cannot complete for this module. `terraform validate` works normally.
- ACM certificates for `aliases` must live in **us-east-1**, regardless of where the rest of the stack runs. The same applies to a WAFv2 web ACL passed as `web_acl_id`.
- Access logging requires a bucket with ACLs enabled, because CloudFront log delivery writes objects with an ACL. The example configures such a bucket with `object_ownership = "BucketOwnerPreferred"`.
- `wait_for_deployment` defaults to true, so applies wait several minutes for the distribution to propagate. Set it to false in fast iteration loops.

## Migrating from the previous version

The old module used `forwarded_values`, which pre-dates cache policies, and an Origin Access Identity. It also had two defects that `terraform validate` could not catch, because both variables defaulted to empty:

- `logging_config` read `var.cloudfront_logging_config.s3_bucket_name`, an attribute access on a `list(object(...))`. Configuring logging failed at plan with `Can't access attributes on a list of objects`.
- Every origin emitted an `s3_origin_config` block, so any custom origin was invalid.

Inputs are therefore renamed rather than kept compatible:

| Before | Now |
| --- | --- |
| `cloudfront_origin` (list) | `origins` (map keyed by origin ID) |
| `s3_origin_config`, `s3_origin_identity_enabled` | `type = "s3"`, handled with Origin Access Control |
| `cloudfront_default_cache_behavior` (list of one) | `default_cache_behavior` (object) |
| `cloudfront_ordered_cache_behavior` | `ordered_cache_behaviors` |
| `forwarded_values` | `cache_policy_name` / `origin_request_policy_name` |
| `cloudfront_logging_config` (list) | `logging` (object) |
| `restrictions` (list) | `geo_restriction` (object) |
| `distribution_state`, `max_http_version`, `waf_acl_id` | `enabled`, `http_version`, `web_acl_id` |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
