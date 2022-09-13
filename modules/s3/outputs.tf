output "bucket_domain_name" {
    value = {for s3_bucket in var.s3_bucket_name: s3_bucket=>aws_s3_bucket.s3_buket[s3_bucket].bucket_domain_name}
}

output "bucket_id" {
    value = {for s3_bucket in var.s3_bucket_name: s3_bucket=>aws_s3_bucket.s3_buket[s3_bucket].id}
}