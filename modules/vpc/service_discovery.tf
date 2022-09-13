/*
resource "aws_service_discovery_public_dns_namespace" "this" {
  count = var.service_discovery_public_dns_namespace_name !=null ? 1:0
  name        = var.service_discovery_public_dns_namespace_name
  description  = var.service_discovery_public_dns_namespace_description 
  
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  count = var.service_discovery_private_dns_namespace_name !=null ? 1:0
  name        = var.service_discovery_private_dns_namespace_name
  description = var.service_discovery_private_dns_namespace_description 
  vpc         = var.service_discovery_private_dns_namespace_name != null ? var.vpc_id:null

}

resource "aws_service_discovery_http_namespace" "this" {
  count = var.service_discovery_http_dns_namespace_name !=null ? 1:0
  name        = var.service_discovery_http_dns_namespace_name
  description  = var.service_discovery_http_dns_namespace_description 

}

resource "aws_service_discovery_service" "this" {
  count = var.service_discovery_name !=null ? 1:0
  name                                    = var.service_discovery_name
  description                             = var.service_discovery_description
  namespace_id                            = var.service_discovery_namespace_id

  dynamic "dns_config" {
    for_each = var.dns_config
    content {
      namespace_id      = dns_config.value.namespace_id
      dynamic "dns_records" {
        for_each = dns_config.value.dns_records
        content {
          ttl   = dns_records.value.ttl
          type  = dns_records.value.type
        }
      }
    }
  }

  dynamic "health_check_config" {
    for_each = var.health_check_config
    content {
      failure_threshold    = health_check_config.value.failure_threshold
      resource_path = health_check_config.value.resource_path
      type  = health_check_config.value.type
    }
  }  

  dynamic "health_check_custom_config" {
    for_each = var.service_discovery_public_dns_namespace_name != null ? var.health_check_custom_config:[]
    content {
      failure_threshold   = health_check_custom_config.value.failure_threshold
    }
  }  

}
*/