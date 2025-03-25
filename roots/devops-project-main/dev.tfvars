greeting = "Hi"

# VPC tfvars
project_name = "redhat-eks-cluster-dev"
cidr_block   = "192.168.0.0/16"
public_subnets = [
  "192.168.1.0/24",
  "192.168.2.0/24",
  "192.168.3.0/24"
]
private_subnets = [
  "192.168.4.0/24",
  "192.168.5.0/24",
  "192.168.6.0/24"
]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EKS tfvars
cluster_name                  = "redhat-eks-cluster-dev"
kubernetes_version            = "1.31"
max_session_duration_cluster  = 43200
eks_worker_node               = "redhat-eks-worker-node"
instance_type                 = "t3.small"
desired_capacity              = 2
max_size                      = 4
min_size                      = 1
on_demand_base_capacity       = 0
on_demand_percentage          = 20
spot_max_price                = "0.0464"
key_name                      = "eks-key"
github_actions_terraform_role = "GitHubActionsTerraformIAMrole"

# # Autoscaler
# asg_name                           = "redhat-eks-cluster-dev-nodes"
# role_name                          = "cluster_autoscaler"
# policy_name                        = "cluster_autoscaler_policy"
# aws_oidc_provider_arn              = "arn:aws:iam::539247466139:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D0BA4F2D549CA4763A7A95A488A22E8E"
# cluster_autoscaler_service_account = "cluster-autoscaler"
# # eks_cluster_arn = "arn:aws:eks:us-east-1:340924313311:cluster/temporary-eks-cluster-dev"
