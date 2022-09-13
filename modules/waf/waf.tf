resource "aws_wafv2_web_acl" "this" {
    default_action {
      allow {}
    }
    description = var.description
    name = var.name

    scope = var.scope
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name = var.metric_name
      sampled_requests_enabled = var.sampled_requests_enabled
    }
    tags = {
        Terraform          = true
        Environment        = var.environment
        Name               = "${var.name}-waf"
    }
}

resource "aws_wafv2_web_acl_association" "this" {
  depends_on = [ "aws_wafv2_web_acl.this" ]
  resource_arn = var.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}