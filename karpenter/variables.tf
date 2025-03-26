variable "eks_cluster_tls_cert_oidc" {
  type = string
}

variable "oidc_thumbprint" {
  type = string
}

variable "worker_node_iam_role" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "eks_cluster_endpoint" {
  type = string
}
