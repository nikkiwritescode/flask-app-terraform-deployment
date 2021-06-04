variable "app_name" {}
variable "env_prefix" {}
variable "git_username" { sensitive = true }
variable "git_token" { sensitive = true }
variable "secret_name" {}
variable "avail_zone_1" {}
variable "avail_zone_2" {}
variable "instance_type" {}
variable "my_ip" {}
variable "my_public_key_location" {}
variable "subnet_cidr_block_1" {}
variable "subnet_cidr_block_2" {}
variable "vpc_cidr_block" {}