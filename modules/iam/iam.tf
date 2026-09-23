resource "aws_iam_role" "this" {
  count              = length(var.iam_role)
  name               = lookup(var.iam_role[count.index], "name", null)
  assume_role_policy = lookup(var.iam_role[count.index], "assume_role_policy", null)
  tags = {
    Terraform   = true
    Environment = var.environment
    Project     = var.project_name
    Name        = "${lookup(var.iam_role[count.index], "name", null)}"
  }

}

resource "aws_iam_role_policy" "this" {
  count  = length(var.iam_role_policy)
  name   = lookup(var.iam_role_policy[count.index], "name", null)
  role   = lookup(var.iam_role_policy[count.index], "role_id", null)
  policy = lookup(var.iam_role_policy[count.index], "policy", null)
}
