output "aws_cognito_user_pool_id" {
  description = "Map of user pool name to user pool ID."
  value       = { for user_pool_name in var.user_pool_name : user_pool_name => aws_cognito_user_pool.this[user_pool_name].id }
}

output "aws_cognito_identity_pool_id" {
  description = "Map of identity pool name to identity pool ID."
  value       = { for identity_pool_name in var.identity_pool_name : identity_pool_name => aws_cognito_identity_pool.this[identity_pool_name].id }
}