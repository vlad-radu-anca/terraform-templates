resource "aws_security_group" "this" {
  count = length(var.security_group)
  name = "${lookup(var.security_group[count.index], "name", null)}"
  vpc_id                 = lookup(var.security_group[count.index], "vpc_id", null)
 
  dynamic "ingress" {
    for_each = lookup(var.security_group[count.index], "sg_rules_ingress", null)
    content{
      cidr_blocks = ingress.value.cidr_blocks
      from_port = ingress.value.from_port
      protocol = ingress.value.protocol
      security_groups = ingress.value.security_groups
      self = ingress.value.self
      to_port = ingress.value.to_port
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = lookup(var.security_group[count.index], "sg_rules_egress", null)
    content{
      cidr_blocks = egress.value.cidr_blocks
      from_port = egress.value.from_port
      protocol = egress.value.protocol
      security_groups = egress.value.security_groups
      self = egress.value.self
      to_port = egress.value.to_port
      description = egress.value.description
    }
  }

  tags = {
      Terraform          = true
      Environment        = var.environment
      Name               = "${lookup(var.security_group[count.index], "name", null)}-sg"
  }
}