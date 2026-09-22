output "cluster_identifier" {
  description = "Aurora cluster identifier."
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "Aurora cluster ARN."
  value       = aws_rds_cluster.this.arn
}

output "cluster_resource_id" {
  description = "Cluster resource ID, used in IAM database authentication policies."
  value       = aws_rds_cluster.this.cluster_resource_id
}

output "endpoint" {
  description = "Writer endpoint of the cluster."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint, load balanced across the reader instances."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "Port the cluster listens on."
  value       = aws_rds_cluster.this.port
}

output "database_name" {
  description = "Name of the initial database."
  value       = aws_rds_cluster.this.database_name
}

output "master_username" {
  description = "Master username."
  value       = aws_rds_cluster.this.master_username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password (only when `manage_master_user_password` is true)."
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "ID of the security group created for the cluster, or null when existing groups were supplied."
  value       = try(aws_security_group.this[0].id, null)
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group in use."
  value       = aws_rds_cluster.this.db_subnet_group_name
}

output "cluster_parameter_group_name" {
  description = "Name of the cluster parameter group in use."
  value       = aws_rds_cluster.this.db_cluster_parameter_group_name
}

output "monitoring_role_arn" {
  description = "ARN of the Enhanced Monitoring IAM role, if the module created one."
  value       = try(aws_iam_role.monitoring[0].arn, null)
}

output "instances" {
  description = "Cluster instances keyed by the `instances` map key: identifier, endpoint, ARN and whether the instance is the writer."
  value = {
    for k, i in aws_rds_cluster_instance.this : k => {
      identifier = i.identifier
      endpoint   = i.endpoint
      arn        = i.arn
      is_writer  = i.writer
    }
  }
}
