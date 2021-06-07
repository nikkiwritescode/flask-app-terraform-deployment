output "app-sg" {
    value = aws_security_group.app-sg
}

output "elb-sg" {
    value = aws_security_group.elb-sg
}

output "ec2-instance-profile-flask-dynamo-access" {
    value = aws_iam_instance_profile.flask_ec2_instance_profile
}