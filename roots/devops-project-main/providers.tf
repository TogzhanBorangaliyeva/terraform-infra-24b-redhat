terraform {
  backend "s3" {
    bucket  = "539247466139-state-bucket-dev"
    key     = "dev.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
