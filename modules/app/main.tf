data "template_file" "init" {
  template = "${file("./modules/app/ec2-user-data.sh.tpl")}"
}

resource "aws_placement_group" "front-end" {
  name     = "${var.app_name}-${var.env_prefix}-front-end-pg"
  strategy = "spread"
}

resource "aws_launch_template" "instance_template" {
  iam_instance_profile {
    name = var.instance_profile
  }
  name = "${var.app_name}-${var.env_prefix}-instance"
  image_id = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.app_security_group_id]
  user_data = base64encode(data.template_file.init.rendered)

  placement {
    group_name = aws_placement_group.front-end.name
  }
}

resource "aws_autoscaling_group" "app-asg" {
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = [var.subnet_ids.0, var.subnet_ids.1, var.subnet_ids.2]
  target_group_arns   = [var.elb_target_group.arn]

  launch_template {
    id      = aws_launch_template.instance_template.id
  }

  tags = [
    {
      key                 = "Environment"
      value               = var.env_prefix
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = var.app_name
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.app_name}-${var.env_prefix}-instance"
      propagate_at_launch = true
    },
  ]
}