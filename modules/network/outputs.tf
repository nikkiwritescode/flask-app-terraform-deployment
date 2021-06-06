output "vpc" {
    value = aws_vpc.app-vpc
}

output "subnet-1" {
    value = aws_subnet.app-subnet-1
}

output "subnet-2" {
    value = aws_subnet.app-subnet-2
}

output "elb_public_dns" {
  value = aws_lb.app-lb.dns_name
}

output "gateway" {
   value = aws_internet_gateway.app-igw
}