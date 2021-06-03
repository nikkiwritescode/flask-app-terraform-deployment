data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_instance_1" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  iam_instance_profile = var.instance_profile

  availability_zone      = var.avail_zone_1
  subnet_id              = var.subnet_1_id
  vpc_security_group_ids = [var.security_group_id]

  key_name = var.key_pair_name

  user_data = file("modules/app/ec2-user-data.sh")

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-instance-1"
  }
}

resource "aws_instance" "app_instance_2" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  availability_zone      = var.avail_zone_2
  subnet_id              = var.subnet_2_id
  vpc_security_group_ids = [var.security_group_id]

  key_name = var.key_pair_name

  user_data = file("modules/app/ec2-user-data.sh")

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-instance-2"
  }
}