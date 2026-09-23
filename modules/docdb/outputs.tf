output "docdb_cluster_endppoint" {
  description = "Writer endpoint of the DocumentDB cluster. Note the historical spelling of this output name."
  value       = aws_docdb_cluster.this[0].endpoint
}
