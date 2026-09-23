output "lambda_arn" {
  description = "Map of function name to function ARN."
  value       = { for function_name in var.function_name : function_name => aws_lambda_function.this[function_name].arn }
}