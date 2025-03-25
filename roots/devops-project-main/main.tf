# DO NOT REMOVE DUMMY MODULE references and their code, they should remain as examples
module "module1" {
  source = "../../dummy-module"
  # ... any required variables for module1
  greeting = var.greeting

}

# VPC module
module "vpc" {
  source             = "../../vpc-module"
  project_name       = var.project_name
  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

# #EKS module
# module "eks" {
#   source                       = "../../eks-cluster-module"
#   public_subnet_ids            = module.vpc.public_subnet_ids
#   vpc_id                       = module.vpc.vpc_id
#   cluster_name                 = var.cluster_name
#   kubernetes_version           = var.kubernetes_version
#   max_session_duration_cluster = var.max_session_duration_cluster

#   eks_worker_node               = var.eks_worker_node
#   instance_type                 = var.instance_type
#   desired_capacity              = var.desired_capacity
#   max_size                      = var.max_size
#   min_size                      = var.min_size
#   on_demand_base_capacity       = var.on_demand_base_capacity
#   on_demand_percentage          = var.on_demand_percentage
#   spot_max_price                = var.spot_max_price
#   key_name                      = var.key_name
#   github_actions_terraform_role = var.github_actions_terraform_role
# }

# data "aws_eks_cluster_auth" "eks_cluster_auth" {
#   name = module.eks.cluster_name
# }

# provider "kubernetes" {
#   host                   = module.eks.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
# }

# data "aws_caller_identity" "current" {}

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   depends_on = [
#     module.eks
#   ]

#   data = {
#     mapRoles = <<EOT
# - rolearn: ${module.eks.eks_worker_role_arn}
#   username: system:node:{{EC2PrivateDNSName}}
#   groups:
#     - system:bootstrappers
#     - system:nodes
#     - system:masters
# - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.github_actions_terraform_role}
#   username: terraform
#   groups:
#     - system:masters
# EOT
#     # Add the IAM user `mike` here
#     mapUsers = <<EOT
# - userarn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/mike
#   username: mike
#   groups:
#     - system:masters
# EOT
#   }
# }

# #Autoscaler
# module "cluster_autoscaler" {
#   source       = "../../autoscaler"
#   asg_name     = var.asg_name
#   cluster_name = var.cluster_name
#   role_name    = var.role_name
#   policy_name  = var.policy_name
#   #   eks_cluster_arn                    = var.eks_cluster_arn
#   aws_oidc_provider_arn              = var.aws_oidc_provider_arn
#   cluster_autoscaler_service_account = var.cluster_autoscaler_service_account
# }