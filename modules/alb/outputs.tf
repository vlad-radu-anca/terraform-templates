
output "load_balancer_arn" {
    value = aws_lb.this[0].arn
}

output "target_group_arn" {
    value = zipmap(aws_lb_target_group.this[*].name, aws_lb_target_group.this[*].id)
}
