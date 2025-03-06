output "vpc_id" {
  value = aws_vpc.k8svpc.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}
