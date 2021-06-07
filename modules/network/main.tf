###
### Load Balancing
###

resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.elb_security_group_id]
  subnets            = [
    aws_subnet.app-subnet-1.id, 
    aws_subnet.app-subnet-2.id, 
    aws_subnet.app-subnet-3.id
  ]

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-elb"
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "app-lb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app-vpc.id}"

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/gtg"
    port                = "8000"
    interval            = 30
  }
}

resource "aws_lb_listener" "app_front_end" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"

    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

###
### Internet Gateway
###

resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

###
### VPC and Subnets
###

resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name    = "${var.app_name}-${var.env_prefix}-vpc"
    vpc_env = "Development"
  }
}

resource "aws_subnet" "app-subnet-1" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.subnet_cidr_block_1
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-${var.env_prefix}-subnet-1"
  }
}

resource "aws_subnet" "app-subnet-2" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.subnet_cidr_block_2
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-${var.env_prefix}-subnet-2"
  }
}

resource "aws_subnet" "app-subnet-3" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.subnet_cidr_block_3
  availability_zone = var.availability_zone_3
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-${var.env_prefix}-subnet-3"
  }
}

###
### Route Tables and Route Table/Subnet Associations
###

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_route_table_association" "b-rtb-subnet" {
  subnet_id      = aws_subnet.app-subnet-2.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_route_table_association" "c-rtb-subnet" {
  subnet_id      = aws_subnet.app-subnet-3.id
  route_table_id = aws_route_table.app-route-table.id
}