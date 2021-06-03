output "sg" {
    value = aws_security_group.app-sg
}

output "key-pair-name" {
    value = aws_key_pair.ssh-key.key_name
}

output "ec2-instance-profile-flask-dynamo-access" {
    value = aws_iam_instance_profile.flask_ec2_instance_profile
}