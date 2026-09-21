output "id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.this.arn
}

output "resource_id" {
  description = "RDS resource ID (used for IAM database authentication policies)."
  value       = aws_db_instance.this.resource_id
}

output "address" {
  description = "DNS hostname of the primary instance."
  value       = aws_db_instance.this.address
}

output "endpoint" {
  description = "Connection endpoint of the primary instance in `address:port` form."
  value       = aws_db_instance.this.endpoint
}

output "port" {
  description = "Port the database listens on."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username."
  value       = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password (only when `manage_master_user_password` is true)."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "ID of the security group created for the database."
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group in use."
  value       = aws_db_instance.this.db_subnet_group_name
}

output "parameter_group_name" {
  description = "Name of the parameter group in use."
  value       = aws_db_instance.this.parameter_group_name
}

output "option_group_name" {
  description = "Name of the option group in use."
  value       = aws_db_instance.this.option_group_name
}

output "monitoring_role_arn" {
  description = "ARN of the Enhanced Monitoring IAM role, if created."
  value       = try(aws_iam_role.monitoring[0].arn, null)
}

output "replica_endpoints" {
  description = "Connection endpoints of the read replicas."
  value       = aws_db_instance.replica[*].endpoint
}

output "replica_ids" {
  description = "Identifiers of the read replicas."
  value       = aws_db_instance.replica[*].id
}
