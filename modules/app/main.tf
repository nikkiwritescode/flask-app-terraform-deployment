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
  ami           = "ami-0f9c27d16302904d1"
  instance_type = var.instance_type
  iam_instance_profile = var.instance_profile

  availability_zone      = var.avail_zone_1
  subnet_id              = var.subnet_1_id
  vpc_security_group_ids = [var.app_security_group_id]

  key_name = var.key_pair_name

  user_data = data.template_file.init.rendered

  depends_on = [var.internet_gateway]

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-instance-1"
  }
}

resource "aws_instance" "app_instance_2" {
  ami           = "ami-0f9c27d16302904d1"
  instance_type = var.instance_type
  iam_instance_profile = var.instance_profile

  availability_zone      = var.avail_zone_2
  subnet_id              = var.subnet_2_id
  vpc_security_group_ids = [var.app_security_group_id]

  key_name = var.key_pair_name

  user_data = data.template_file.init.rendered

  depends_on = [var.internet_gateway]

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-instance-2"
  }
}

data "template_file" "init" {
  template = "${file("./modules/app/ec2-user-data.sh.tpl")}"
}