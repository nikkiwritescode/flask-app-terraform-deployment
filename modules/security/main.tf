resource "aws_security_group" "app-sg" {
  name   = "${var.app_name}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-app-sg"
  }
}

resource "aws_security_group_rule" "app-sg-rule" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = aws_security_group.app-sg.id // The group to attach the rule to
  source_security_group_id = aws_security_group.elb-sg.id // The group to specify as source
}

resource "aws_security_group" "elb-sg" {
  name   = "${var.app_name}-elb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.app_name}-${var.env_prefix}-elb-sg"
  }
}

resource "aws_security_group_rule" "elb-sg-rule" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = aws_security_group.elb-sg.id // The group to attach the rule to
  source_security_group_id = aws_security_group.app-sg.id // The group to specify as source
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.app_name}-server-key"
  public_key = file(var.my_public_key_location)
}

resource "aws_iam_role" "dynamo_and_secrets_role_for_ec2" {
  name = "dynamo_and_secrets_role_for_ec2"
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
    }]
  })

  tags = {
      tag-key = "dynamo_and_secrets_role_for_ec2"
  }
}

resource "aws_iam_instance_profile" "flask_ec2_instance_profile" {
  name = "flask_ec2_instance_profile"
  role = aws_iam_role.dynamo_and_secrets_role_for_ec2.name
}

resource "aws_iam_role_policy" "dynamo_role_for_ec2_policy" {
    name = "dynamo_role_for_ec2_policy"
    role = aws_iam_role.dynamo_and_secrets_role_for_ec2.id

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

resource "aws_iam_policy" "secrets_policy_for_ec2" {
  name        = "secrets-policy-for-ec2"
  description = "Policy which allows the EC2 instances to pull secrets from AWS Secrets Manager."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Effect = "Allow",
        Action = [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:ListSecrets"
        ],
        Resource = [
            "${aws_secretsmanager_secret_version.git_access_token.secret_id}"
        ]
    },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_role_attachment" {
  role       = aws_iam_role.dynamo_and_secrets_role_for_ec2.id
  policy_arn = aws_iam_policy.secrets_policy_for_ec2.arn
}

resource "aws_secretsmanager_secret" "git_access_token" {
  name = "${var.app_name}-${var.env_prefix}-${var.secret_name}"
}

resource "aws_secretsmanager_secret_version" "git_access_token" {
  secret_id     = aws_secretsmanager_secret.git_access_token.id
  secret_string = var.git_token
}