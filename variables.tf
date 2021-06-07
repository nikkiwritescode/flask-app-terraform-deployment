variable "app_name" {}
variable "env_prefix" {}
variable "availability_zones" {}
variable "asg_desired_capacity" {}
variable "asg_max_size" {}
variable "asg_min_size" {}
variable "instance_type" {}
variable "ami_id" {}
variable "my_ip" {}
variable "my_public_key_location" {
  default = "~/.ssh/id_rsa.pub"
}
variable "my_public_key" {
  default = "empty"
}
variable "subnet_cidr_blocks" {}
variable "vpc_cidr_block" {}