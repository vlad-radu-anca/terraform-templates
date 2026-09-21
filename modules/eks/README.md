# AWS EKS module

Amazon EKS cluster with managed node groups, built around the current EKS access model rather than the legacy `aws-auth` ConfigMap.

What you get:

- **Control plane** with private endpoint by default, optional public endpoint restricted by CIDR, control-plane logs in a CloudWatch log group with configurable retention and KMS key, optional envelope encryption of Kubernetes secrets.
- **Access entries** (`authentication_mode = "API"`) with EKS access policies. No ConfigMap editing, no `kubectl` dependency inside Terraform.
- **Managed add-ons** with correct ordering: `vpc-cni`, `kube-proxy` and `eks-pod-identity-agent` are installed before the node groups, `coredns` after. Versions resolve to the latest compatible release unless pinned.
- **Managed node groups** as a `map(object)`. Each group gets its own launch template with IMDSv2 required, encrypted `gp3` root volume, detailed monitoring and propagated tags. Supports labels, taints, spot capacity, per-group subnets and per-group Kubernetes version for staged upgrades.
- **IAM OIDC provider** so workloads can use IRSA immediately. The node role includes `AmazonSSMManagedInstanceCore` so you can reach nodes with Session Manager instead of SSH.
- `desired_size` is ignored after creation so cluster-autoscaler or Karpenter can own it.

## Usage

```hcl
module "eks" {
  source = "git::https://github.com/vlad-radu-anca/terraform-templates.git//modules/eks?ref=v1.0.0"

  project_name       = "demo"
  environment        = "prod"
  kubernetes_version = "1.31"

  subnet_ids                      = module.vpc.private_subnet_ids
  cluster_api_allowed_cidr_blocks = ["10.0.0.0/8"]

  node_groups = {
    general = {
      instance_types = ["m6i.large"]
      min_size       = 2
      max_size       = 6
    }
  }

  access_entries = {
    admins = {
      principal_arn = "arn:aws:iam::123456789012:role/platform-admin"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
}
```

Then:

```sh
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

A complete example with on-demand and spot node groups is in [`examples/complete`](examples/complete).

## Design notes

- `bootstrap_self_managed_addons` is set to `false` so the add-ons are fully managed by Terraform from the first apply. Without this, EKS installs its own copies and the first `aws_eks_addon` apply has to overwrite them.
- Node groups depend on the "before compute" add-ons, so nodes never join a cluster without `vpc-cni`.
- The launch template sets `http_put_response_hop_limit = 2`, which allows pods on the node network to reach IMDS through the node but blocks pods behind a second hop.
- The cluster security group is the one EKS creates. `cluster_api_allowed_cidr_blocks` adds ingress rules to it so a VPN or bastion range can reach the private API endpoint.
- The `tls` provider is used only to read the OIDC issuer certificate thumbprint.

## Not included (on purpose)

- Karpenter, cluster-autoscaler, ALB controller and other in-cluster controllers. They belong in a separate layer applied after the cluster exists.
- Self-managed node groups and Fargate profiles.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
