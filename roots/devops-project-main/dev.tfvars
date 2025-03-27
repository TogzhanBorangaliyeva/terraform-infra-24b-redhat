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
instance_type                 = "t3.medium"
desired_capacity              = 2
max_size                      = 2
min_size                      = 1
on_demand_base_capacity       = 0
on_demand_percentage          = 20
spot_max_price                = "0.0464"
key_name                      = "eks-key"
github_actions_terraform_role = "GitHubActionsTerraformIAMrole"

