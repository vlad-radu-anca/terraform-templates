resource "aws_cloudfront_public_key" "cloudfront_public_key" {
  for_each    = var.keys
  comment     = each.value.comment
  encoded_key = file(each.value.file_name)
  name        = each.key
  lifecycle {
    ignore_changes = [encoded_key]
  }
}

resource "aws_cloudfront_key_group" "keygroup" {
  comment = var.comment
  items   = values(aws_cloudfront_public_key.cloudfront_public_key)[*].id
  name    = var.key_group_name
}