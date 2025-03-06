greeting = "Hi"

# VPC tfvars
project_name = "redhat-eks-cluster-prod"
cidr_block   = "192.168.0.0/16"
public_subnets = [
  "192.168.20.0/24",
  "192.168.21.0/24",
  "192.168.22.0/24"
]
private_subnets = [
  "192.168.23.0/24",
  "192.168.24.0/24",
  "192.168.25.0/24"
]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EKS tfvars
cluster_name                 = "redhat-eks-cluster-prod"
kubernetes_version           = "1.31"
eks_worker_node              = "redhat-eks-worker-node-prod"
instance_type                = "t3.xlarge"
desired_capacity             = 5
max_size                     = 8
min_size                     = 3
on_demand_base_capacity      = 2
on_demand_percentage         = 50
spot_max_price               = "0.08"
key_name                     = "eks-key-prod"
max_session_duration_cluster = 43200
