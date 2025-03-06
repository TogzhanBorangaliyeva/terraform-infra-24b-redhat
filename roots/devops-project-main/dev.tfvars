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
