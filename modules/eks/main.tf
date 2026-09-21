locals {
  cluster_name = coalesce(var.cluster_name, "${var.project_name}-${var.environment}")

  create_cluster_role = var.cluster_iam_role_arn == null
  create_node_role    = var.node_iam_role_arn == null && length(var.node_groups) > 0
  cluster_role_arn    = local.create_cluster_role ? aws_iam_role.cluster[0].arn : var.cluster_iam_role_arn
  node_role_arn       = local.create_node_role ? aws_iam_role.node[0].arn : var.node_iam_role_arn

  addons_before_compute = { for k, v in var.cluster_addons : k => v if v.before_compute }
  addons_after_compute  = { for k, v in var.cluster_addons : k => v if !v.before_compute }

  tags = merge(
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
    },
    var.tags,
  )
}

data "aws_partition" "current" {}

########################################
# Control-plane IAM role
########################################

data "aws_iam_policy_document" "cluster_assume" {
  count = local.create_cluster_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  count = local.create_cluster_role ? 1 : 0

  name_prefix        = "${local.cluster_name}-cluster-"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = local.create_cluster_role ? toset([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy",
  ]) : toset([])

  role       = aws_iam_role.cluster[0].name
  policy_arn = each.value
}

########################################
# Control-plane logging
########################################

resource "aws_cloudwatch_log_group" "cluster" {
  count = length(var.enabled_cluster_log_types) > 0 ? 1 : 0

  # EKS writes to this exact name; creating it first lets us control retention and encryption.
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id

  tags = local.tags
}

########################################
# Cluster
########################################

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  version  = var.kubernetes_version
  role_arn = local.cluster_role_arn

  # Add-ons are managed explicitly below rather than by the EKS bootstrap defaults.
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access ? var.endpoint_public_access_cidrs : null
    security_group_ids      = var.cluster_security_group_additional_ids
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  upgrade_policy {
    support_type = var.support_type
  }

  dynamic "kubernetes_network_config" {
    for_each = var.service_ipv4_cidr != null ? [1] : []
    content {
      service_ipv4_cidr = var.service_ipv4_cidr
    }
  }

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_kms_key_arn != null ? [1] : []
    content {
      resources = ["secrets"]
      provider {
        key_arn = var.cluster_encryption_kms_key_arn
      }
    }
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = merge(local.tags, { Name = local.cluster_name })

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_cloudwatch_log_group.cluster,
  ]
}

# Allow trusted networks (VPN, bastions, CI runners) to reach the private API endpoint.
resource "aws_vpc_security_group_ingress_rule" "api" {
  for_each = toset(var.cluster_api_allowed_cidr_blocks)

  security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description       = "Kubernetes API from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  tags = local.tags
}

########################################
# OIDC provider (IRSA)
########################################

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]

  tags = merge(local.tags, { Name = "${local.cluster_name}-oidc" })
}

########################################
# Add-ons (before compute)
########################################

data "aws_eks_addon_version" "this" {
  for_each = var.cluster_addons

  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.this.version
  most_recent        = true
}

resource "aws_eks_addon" "before_compute" {
  for_each = local.addons_before_compute

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = coalesce(each.value.version, data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = each.value.configuration_values
  service_account_role_arn    = each.value.service_account_role_arn
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  preserve                    = each.value.preserve

  tags = local.tags
}

########################################
# Node IAM role
########################################

data "aws_iam_policy_document" "node_assume" {
  count = local.create_node_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  count = local.create_node_role ? 1 : 0

  name_prefix        = "${local.cluster_name}-node-"
  assume_role_policy = data.aws_iam_policy_document.node_assume[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = local.create_node_role ? toset(concat([
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ], var.node_iam_role_additional_policy_arns)) : toset([])

  role       = aws_iam_role.node[0].name
  policy_arn = each.value
}

########################################
# Managed node groups
########################################

resource "aws_launch_template" "node" {
  for_each = var.node_groups

  name_prefix = "${local.cluster_name}-${each.key}-"
  description = "EKS managed node group ${each.key} for ${local.cluster_name}"

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.disk_size
      volume_type           = each.value.disk_type
      encrypted             = true
      kms_key_id            = each.value.disk_kms_key_id
      delete_on_termination = true
    }
  }

  # IMDSv2 only, hop limit 2 so pods in hostNetwork=false cannot reach node credentials.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.value
      tags          = merge(local.tags, each.value.tags, { Name = "${local.cluster_name}-${each.key}" })
    }
  }

  tags = merge(local.tags, { Name = "${local.cluster_name}-${each.key}" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = local.node_role_arn
  subnet_ids      = coalesce(each.value.subnet_ids, var.subnet_ids)

  version         = each.value.kubernetes_version
  release_version = each.value.ami_release_version
  ami_type        = each.value.ami_type
  capacity_type   = each.value.capacity_type
  instance_types  = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable_percentage = each.value.max_unavailable_percentage
  }

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = aws_launch_template.node[each.key].latest_version
  }

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(local.tags, each.value.tags, { Name = "${local.cluster_name}-${each.key}" })

  lifecycle {
    create_before_destroy = true
    # Let cluster-autoscaler / Karpenter own desired_size after creation.
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node,
    aws_eks_addon.before_compute,
  ]
}

########################################
# Add-ons (after compute)
########################################

resource "aws_eks_addon" "after_compute" {
  for_each = local.addons_after_compute

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = coalesce(each.value.version, data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = each.value.configuration_values
  service_account_role_arn    = each.value.service_account_role_arn
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  preserve                    = each.value.preserve

  tags = local.tags

  depends_on = [aws_eks_node_group.this]
}

########################################
# Access entries
########################################

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  type              = each.value.type
  kubernetes_groups = each.value.kubernetes_groups
  user_name         = each.value.user_name

  tags = local.tags
}

locals {
  policy_associations = merge([
    for entry_key, entry in var.access_entries : {
      for assoc_key, assoc in entry.policy_associations :
      "${entry_key}/${assoc_key}" => merge(assoc, { entry_key = entry_key })
    }
  ]...)
}

resource "aws_eks_access_policy_association" "this" {
  for_each = local.policy_associations

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.this[each.value.entry_key].principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.type == "namespace" ? each.value.access_scope.namespaces : null
  }
}

data "aws_region" "current" {}
