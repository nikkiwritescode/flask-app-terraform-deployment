output "sg" {
    value = aws_security_group.app-sg
}

output "key-pair-name" {
    value = aws_key_pair.ssh-key.key_name
}