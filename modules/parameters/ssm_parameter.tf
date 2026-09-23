resource "aws_ssm_parameter" "this" {
  count           = length(var.ssm_parameter)
  name            = lookup(var.ssm_parameter[count.index], "name", null)
  type            = lookup(var.ssm_parameter[count.index], "type", null)
  value           = lookup(var.ssm_parameter[count.index], "value", null)
  description     = lookup(var.ssm_parameter[count.index], "description", null)
  tier            = lookup(var.ssm_parameter[count.index], "tier", null)
  key_id          = lookup(var.ssm_parameter[count.index], "key_id", null)
  overwrite       = lookup(var.ssm_parameter[count.index], "overwrite", null)
  allowed_pattern = lookup(var.ssm_parameter[count.index], "allowed_pattern", null)
  data_type       = lookup(var.ssm_parameter[count.index], "data_type", null)
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${lookup(var.ssm_parameter[count.index], "name", null)}-ssm_parameter"
  }
}