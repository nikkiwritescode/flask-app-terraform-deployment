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
  availability_zone = var.avail_zone_1
  tags = {
    Name = "${var.app_name}-${var.env_prefix}-subnet-1"
  }
}

resource "aws_subnet" "app-subnet-2" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.subnet_cidr_block_2
  availability_zone = var.avail_zone_2
  tags = {
    Name = "${var.app_name}-${var.env_prefix}-subnet-2"
  }
}

resource "aws_elb" "app-elb" {
  name               = "app-elb"
  subnets = [aws_subnet.app-subnet-1.id, aws_subnet.app-subnet-2.id]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                 = [var.instance_id_1, var.instance_id_2]
  cross_zone_load_balancing = true
  idle_timeout              = 30

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-elb"
  }
}

resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

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