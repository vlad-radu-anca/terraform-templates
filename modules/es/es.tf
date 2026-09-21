resource "aws_elasticsearch_domain" "this" {
  domain_name     = var.domain_name
  access_policies = var.access_policies
  ebs_options {
    ebs_enabled = lookup(var.ebs_options, "ebs_enabled", false)
    volume_size = lookup(var.ebs_options, "volume_size", 10)
    volume_type = lookup(var.ebs_options, "volume_type", "gp2")
  }
  cluster_config {
    instance_type  = lookup(var.cluster_config, "instance_type", null)
    instance_count = lookup(var.cluster_config, "instance_count", 1)
  }
  vpc_options {
    security_group_ids = lookup(var.vpc_options, "security_group_ids", [])
    subnet_ids         = lookup(var.vpc_options, "subnet_ids", [])
  }

  elasticsearch_version = var.elasticsearch_version
  tags = {
    Terraform   = true
    Environment = var.environment
    Name        = "${var.domain_name}-es-domain"
  }
}

