output "vpc" {
    value = aws_vpc.app-vpc
}

output "subnet_ids" {
    value = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id, aws_subnet.app-subnet-3.id]
}

output "elb_public_dns" {
    value = aws_lb.app-lb.dns_name
}

output "gateway" {
    value = aws_internet_gateway.app-igw
}

output "elb_target_group" {
    value = aws_lb_target_group.app_target_group
}