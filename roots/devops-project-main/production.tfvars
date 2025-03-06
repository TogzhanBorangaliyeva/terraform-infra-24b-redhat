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
