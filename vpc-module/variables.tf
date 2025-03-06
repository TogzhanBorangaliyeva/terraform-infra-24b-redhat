variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "project_name" {
  type        = string
  description = "The project name"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnets"
}
