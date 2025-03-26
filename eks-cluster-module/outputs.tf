output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_worker_role_arn" {
  description = "The ARN of the EKS worker role"
  value       = aws_iam_role.eks_worker_role.arn
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

# needed for oidc (Karpenter)
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "eks_cluster_tls_cert_oidc" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "oidc_thumbprint" {
  value = data.tls_certificate.eks.certificates[0].sha1_fingerprint
}

output "worker_node_iam_role" {
  value = aws_iam_role.eks_worker_role.name
}

output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}