resource "aws_codestarnotifications_notification_rule" "this" {
  for_each    = toset(var.codestar_notification) 
  detail_type = var.detail_type
  event_type_ids = var.event_type_ids
  name     = "${each.value}"
  resource = var.resource
  status = var.status
  dynamic "target" {
    for_each = var.target
    content {
    address = target.value.address
    type = target.value.type
    }
  }
    tags = {
        Terraform                       = true
        Environment                     = var.environment
        Name                            = "${each.value}-codestar"
    }
}