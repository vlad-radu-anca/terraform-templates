#output "nacle_rules" {
#  value = {for nacl_rule in var.nacl_rules:  nacl_rule.protocol => nacl_rule}
#}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "vpc_default_sg" {
  value = [aws_default_security_group.this[0].id]
}

output "vpc_id" {
  value = aws_vpc.this[0].id
}

/*
output "private_namespace_id" {
    value = aws_service_discovery_private_dns_namespace.this[0].id
}
*/
/*
output "service_discovery_service_arn" {
    value = aws_service_discovery_service.this[0].arn
}
*/