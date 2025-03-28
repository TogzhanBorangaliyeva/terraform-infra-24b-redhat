# VPC module
module "vpc" {
  source             = "../../vpc-module"
  project_name       = var.project_name
  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

# EKS module
module "eks" {
  source                       = "../../eks-cluster-module"
  public_subnet_ids            = module.vpc.public_subnet_ids
  vpc_id                       = module.vpc.vpc_id
  cluster_name                 = var.cluster_name
  kubernetes_version           = var.kubernetes_version
  max_session_duration_cluster = var.max_session_duration_cluster

  eks_worker_node               = var.eks_worker_node
  instance_type                 = var.instance_type
  desired_capacity              = var.desired_capacity
  max_size                      = var.max_size
  min_size                      = var.min_size
  on_demand_base_capacity       = var.on_demand_base_capacity
  on_demand_percentage          = var.on_demand_percentage
  spot_max_price                = var.spot_max_price
  key_name                      = var.key_name
  github_actions_terraform_role = var.github_actions_terraform_role
}

# Karpenter module
module "karpenter" {
  source                    = "../../karpenter"
  eks_cluster_tls_cert_oidc = module.eks.eks_cluster_tls_cert_oidc
  oidc_thumbprint           = module.eks.oidc_thumbprint
  worker_node_iam_role      = module.eks.worker_node_iam_role
  cluster_id                = module.eks.cluster_id
  eks_cluster_endpoint      = module.eks.eks_cluster_endpoint
}

# Horizontal Pod Autoscaler module
module "hpa" {
  source = "../../horizontal-autoscaler"
}

module "iam-roles" {
  source = "../../iam-roles"
}


