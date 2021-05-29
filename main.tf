provider "aws" {}

resource "aws_vpc" "main-vpc" {
    cidr_block ="10.0.0.0/16"
    tags = {
        Name = "dev-vpc"
        vpc_env = "Development"
    }
}

resource "aws_subnet" "main-subnet-1" {
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name = "dev-subnet-1"
        vpc_env = "Development"
    }
}