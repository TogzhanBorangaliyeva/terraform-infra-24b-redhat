
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.16.3"

  timeout = 600

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "clusterName"
    value = var.cluster_id
  }

  set {
    name  = "clusterEndpoint"
    value = var.eks_cluster_endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = var.eks_worker_role     #aws_iam_instance_profile.karpenter.name
  }
}
