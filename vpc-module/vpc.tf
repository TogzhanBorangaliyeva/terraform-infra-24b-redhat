resource "aws_vpc" "k8svpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  cidr_block              = var.public_subnets[count.index]
  vpc_id                  = aws_vpc.k8svpc.id
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name                                        = "eks-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.k8svpc.id
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name                                        = "eks-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8svpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8svpc-igw.id
  }

  tags = {
    Name                                        = "${var.project_name}-public-route-table"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name                                        = "${var.project_name}-private-route-table"
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
