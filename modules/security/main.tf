resource "aws_security_group" "app-sg" {
  name   = "${var.app_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-sg"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.app_name}-server-key"
  public_key = file(var.my_public_key_location)
}

resource "aws_iam_role" "dynamo_role_for_ec2" {
  name = "dynamo_role_for_ec2"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
            Service = "ec2.amazonaws.com"
        }
    },
    ]
  })

  tags = {
      tag-key = "dynamo_role_for_ec2"
  }
}

resource "aws_iam_instance_profile" "flask_ec2_instance_profile" {
  name = "flask_ec2_instance_profile"
  role = "${aws_iam_role.dynamo_role_for_ec2.name}"
}

resource "aws_iam_role_policy" "dynamo_role_for_ec2_policy" {
    name = "dynamo_role_for_ec2_policy"
    role = "${aws_iam_role.dynamo_role_for_ec2.id}"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
              Action = [
                "dynamodb:List*",
                "dynamodb:DescribeReservedCapacity*",
                "dynamodb:DescribeLimits",
                "dynamodb:DescribeTimeToLive"
              ]
              Effect = "Allow"
              Sid    = "ListAndDescribe"
              Resource = "*"
            },
            {
              "Sid": "SpecificTableAccessPolicy",
              "Effect": "Allow",
              "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/${var.dynamo_table_name}"
        }
        ]
    })
}