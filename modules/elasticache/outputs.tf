output "elasticache_cluster_endpoint" {
  value = aws_elasticache_cluster.this[0].cache_nodes.0.address
}
