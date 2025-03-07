variable "asg_name" {
  type = string
}

variable "role_name" {
  description = "cluster-autoscaler"
  type        = string
}

variable "policy_name" {
  description = "cluster-autoscaler-policy"
  type        = string
}

variable "aws_oidc_provider_arn" {
  description = "The OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "cluster_autoscaler_service_account" {
  description = "The service account name for Cluster Autoscaler"
  type        = string
}

# variable "eks_cluster_arn" {
#   description = "The ARN of the EKS cluster"
#   type        = string
# }