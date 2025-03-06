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

