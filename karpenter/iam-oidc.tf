### OIDC provider for service account IAM role (to grant access for service account inside AWS)
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]
  url             = var.eks_cluster_tls_cert_oidc
}