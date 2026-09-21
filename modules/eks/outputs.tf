output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane."
  value       = aws_eks_cluster.this.version
}

output "cluster_platform_version" {
  description = "EKS platform version."
  value       = aws_eks_cluster.this.platform_version
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA certificate for the API server."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group EKS created for the control plane and managed node groups."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "ARN of the control-plane IAM role."
  value       = local.cluster_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider, for IRSA trust policies."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL of the cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_iam_role_arn" {
  description = "ARN of the worker node IAM role (null if no node groups)."
  value       = local.node_role_arn
}

output "node_groups" {
  description = "Managed node groups keyed by name: id, arn, status, and resolved AMI release version."
  value = {
    for k, ng in aws_eks_node_group.this : k => {
      id              = ng.id
      arn             = ng.arn
      status          = ng.status
      release_version = ng.release_version
    }
  }
}

output "addons" {
  description = "Installed add-on versions keyed by add-on name."
  value = merge(
    { for k, a in aws_eks_addon.before_compute : k => a.addon_version },
    { for k, a in aws_eks_addon.after_compute : k => a.addon_version },
  )
}

output "kubeconfig_command" {
  description = "AWS CLI command that writes a kubeconfig entry for this cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${data.aws_region.current.region}"
}
