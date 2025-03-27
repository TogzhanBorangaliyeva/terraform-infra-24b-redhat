
data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  depends_on = [
    module.eks
  ]

  data = {
    mapRoles = <<EOT
- rolearn: ${module.eks.eks_worker_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
    - system:masters
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.github_actions_terraform_role}
  username: terraform
  groups:
    - system:masters
EOT
    # Add the IAM user `mike` here
    mapUsers = <<EOT
- userarn: arn:aws:iam::539247466139:user/mike
  username: mike
  groups:
    - system:masters
EOT
  }
}