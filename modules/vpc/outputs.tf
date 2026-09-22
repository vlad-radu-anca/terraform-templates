output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this[0].id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this[0].cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per availability zone."
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per availability zone."
  value       = aws_subnet.private_subnet[*].id
}

output "vpc_default_sg" {
  description = "ID of the VPC default security group, as a single-element list."
  value       = [aws_default_security_group.this[0].id]
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways. One per availability zone when `multiple_nats` is true, otherwise a single gateway."
  value       = aws_nat_gateway.this[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "public_route_table_ids" {
  description = "IDs of the public route tables."
  value       = aws_route_table.public_route_table[*].id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = aws_route_table.private_route_table[*].id
}
