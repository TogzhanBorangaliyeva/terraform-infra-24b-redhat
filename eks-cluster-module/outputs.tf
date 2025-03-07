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