resource "aws_lambda_function" "this" {
    for_each = toset(var.function_name)
    function_name = each.value
    filename = var.filename
    s3_bucket = var.s3_bucket
    s3_key = var.s3_key
    s3_object_version = var.s3_object_version
    handler = var.handler
    role = var.role
    description = var.description
    layers = var.layers
    memory_size = var.memory_size
    runtime = var.runtime
    timeout = var.timeout
    reserved_concurrent_executions = var.reserved_concurrent_executions
    publish = var.publish
    dynamic "vpc_config" {
        for_each = var.vpc_config
        content {
            subnet_ids = vpc_config.value.subnet_ids
            security_group_ids = vpc_config.value.security_group_ids
        }
    }
    dynamic "environment" {
        for_each = var.environment_vars
        content {
            variables = environment.value.variables
        }
    }
    kms_key_arn = var.kms_key_arn
    source_code_hash = var.source_code_hash
    dynamic "file_system_config" {
        for_each = var.file_system_config
        content {
            arn = file_system_config.value.arn
            local_mount_path = file_system_config.value.local_mount_path
        }

    }

}

resource "aws_lambda_permission" "this" {
    count = length(var.lambda_permission)
    action = lookup(var.lambda_permission[count.index], "action", null)
    event_source_token = lookup(var.lambda_permission[count.index], "event_source_token", null)
    function_name = lookup(var.lambda_permission[count.index], "function_name", null)
    principal = lookup(var.lambda_permission[count.index], "principal", null)
    qualifier = lookup(var.lambda_permission[count.index], "qualifier", null)
    source_account = lookup(var.lambda_permission[count.index], "source_account", null)
    source_arn = lookup(var.lambda_permission[count.index], "source_arn", null)
    statement_id = lookup(var.lambda_permission[count.index], "statement_id", null)
    statement_id_prefix = lookup(var.lambda_permission[count.index], "statement_id_prefix", null)
}