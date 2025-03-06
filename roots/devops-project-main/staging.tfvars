greeting = "Hi"

# VPC tfvars
project_name = "redhat-eks-cluster-staging"
cidr_block   = "192.168.0.0/16"
public_subnets = [
  "192.168.10.0/24",
  "192.168.11.0/24",
  "192.168.12.0/24"
]
private_subnets = [
  "192.168.13.0/24",
  "192.168.14.0/24",
  "192.168.15.0/24"
]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EKS tfvars
cluster_name                 = "redhat-eks-cluster-staging"
kubernetes_version           = "1.31"
eks_worker_node              = "redhat-eks-worker-node-staging"
instance_type                = "t3.large"
desired_capacity             = 4
max_size                     = 6
min_size                     = 2
on_demand_base_capacity      = 1
on_demand_percentage         = 30
spot_max_price               = "0.06"
key_name                     = "eks-key-staging"
max_session_duration_cluster = 43200
