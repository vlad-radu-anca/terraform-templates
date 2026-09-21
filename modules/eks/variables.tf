########################################
# Naming / tagging
########################################

variable "project_name" {
  description = "Name of the application/project, used as a prefix when naming resources."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod), used as a prefix when naming resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. Defaults to `<project_name>-<environment>`."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to every resource created by this module."
  type        = map(string)
  default     = {}
}

########################################
# Cluster
########################################

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane, e.g. `1.31`. Null uses the EKS default."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the control-plane ENIs. Use private subnets in at least two AZs."
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable the private API server endpoint."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable the public API server endpoint."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public endpoint when `endpoint_public_access` is true."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_security_group_additional_ids" {
  description = "Extra security groups attached to the control-plane ENIs, in addition to the cluster security group EKS creates."
  type        = list(string)
  default     = []
}

variable "cluster_api_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the API server on port 443 through the cluster security group (e.g. VPN or bastion ranges)."
  type        = list(string)
  default     = []
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes service IPs. Null lets EKS choose."
  type        = string
  default     = null
}

variable "authentication_mode" {
  description = "Cluster access authentication mode: `API` (access entries only, recommended) or `API_AND_CONFIG_MAP`."
  type        = string
  default     = "API"

  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be API or API_AND_CONFIG_MAP."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Grant the IAM identity that creates the cluster admin access via an access entry."
  type        = bool
  default     = true
}

variable "support_type" {
  description = "Upgrade policy: `STANDARD` (14 months of support) or `EXTENDED` (26 months, extra cost)."
  type        = string
  default     = "STANDARD"
}

variable "enabled_cluster_log_types" {
  description = "Control-plane log types to send to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_in_days" {
  description = "Retention for the control-plane CloudWatch log group."
  type        = number
  default     = 90
}

variable "cluster_log_kms_key_id" {
  description = "KMS key ARN for the control-plane log group. Null uses CloudWatch default encryption."
  type        = string
  default     = null
}

variable "cluster_encryption_kms_key_arn" {
  description = "KMS key ARN used to envelope-encrypt Kubernetes secrets. Null disables secrets encryption config."
  type        = string
  default     = null
}

variable "cluster_iam_role_arn" {
  description = "ARN of an existing IAM role for the control plane. Null creates one."
  type        = string
  default     = null
}

########################################
# Add-ons
########################################

variable "cluster_addons" {
  description = <<-EOT
  EKS managed add-ons keyed by add-on name. Set `version` to null for the latest compatible version.
  `before_compute` add-ons are created before the node groups (required for `vpc-cni`, `kube-proxy`, `eks-pod-identity-agent`).
  EOT
  type = map(object({
    version                     = optional(string)
    configuration_values        = optional(string)
    service_account_role_arn    = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    preserve                    = optional(bool, false)
    before_compute              = optional(bool, false)
  }))
  default = {
    vpc-cni                = { before_compute = true }
    kube-proxy             = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    coredns                = {}
  }
}

########################################
# Node groups
########################################

variable "node_iam_role_arn" {
  description = "ARN of an existing IAM role for worker nodes. Null creates one shared by all managed node groups."
  type        = string
  default     = null
}

variable "node_iam_role_additional_policy_arns" {
  description = "Extra managed policy ARNs attached to the module-created node role."
  type        = list(string)
  default     = []
}

variable "node_groups" {
  description = <<-EOT
  Managed node groups keyed by name. Each group gets its own launch template with IMDSv2 enforced and encrypted root volume.
  `subnet_ids` overrides the cluster subnets; `kubernetes_version` overrides the cluster version (for staged upgrades).
  EOT
  type = map(object({
    instance_types             = optional(list(string), ["t3.medium"])
    capacity_type              = optional(string, "ON_DEMAND")
    ami_type                   = optional(string, "AL2023_x86_64_STANDARD")
    ami_release_version        = optional(string)
    kubernetes_version         = optional(string)
    desired_size               = optional(number, 2)
    min_size                   = optional(number, 1)
    max_size                   = optional(number, 3)
    max_unavailable_percentage = optional(number, 33)
    disk_size                  = optional(number, 50)
    disk_type                  = optional(string, "gp3")
    disk_kms_key_id            = optional(string)
    subnet_ids                 = optional(list(string))
    labels                     = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

########################################
# Access entries
########################################

variable "access_entries" {
  description = <<-EOT
  IAM principals granted cluster access (authentication mode `API`). Keyed by a friendly name.
  `policy_associations` maps a name to an EKS access policy ARN and scope, e.g.
  `{ admin = { policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy", access_scope = { type = "cluster" } } }`.
  EOT
  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    kubernetes_groups = optional(list(string), [])
    user_name         = optional(string)
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), {})
  }))
  default = {}
}
