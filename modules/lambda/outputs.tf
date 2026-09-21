output "lambda_arn" {
  value = { for function_name in var.function_name : function_name => aws_lambda_function.this[function_name].arn }
}