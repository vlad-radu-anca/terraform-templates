output "docdb_cluster_endppoint" {
  value = aws_docdb_cluster.this[0].endpoint
}
