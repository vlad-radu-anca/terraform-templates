output "elasticache_cluster_endpoint" {
  description = "Address of the first cache node in the cluster."
  value       = aws_elasticache_cluster.this[0].cache_nodes.0.address
}
