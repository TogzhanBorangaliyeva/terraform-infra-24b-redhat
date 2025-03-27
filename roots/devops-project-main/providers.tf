terraform {
  backend "s3" {
    bucket  = "539247466139-state-bucket-dev"
    key     = "dev.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  }
}