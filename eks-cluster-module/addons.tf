resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.19.2-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_asg]
}

# resource "aws_eks_addon" "coredns" {
#   cluster_name                = aws_eks_cluster.eks_cluster.name
#   addon_name                  = "coredns"
#   addon_version               = "v1.11.4-eksbuild.2"
#   resolve_conflicts_on_update = "PRESERVE"

#   depends_on = [aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_asg]
# }

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.31.3-eksbuild.2"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_asg]
}

# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name                = aws_eks_cluster.eks_cluster.name
#   addon_name                  = "aws-ebs-csi-driver"
#   addon_version               = "v1.39.0-eksbuild.1"
#   resolve_conflicts_on_update = "PRESERVE"

#   depends_on = [aws_eks_cluster.eks_cluster, aws_autoscaling_group.eks_asg]
# }
