variable "app_name" {}
variable "env_prefix" {}
variable "avail_zones" {
  default = "empty"
}
variable "avail_zone_1" {
  default = "empty"
}
variable "avail_zone_2" {
  default = "empty"
}
variable "avail_zone_3" {
  default = "empty"
}
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
variable "subnet_cidr_blocks" {
  default = "empty"
}
variable "subnet_cidr_block_1" {
  default = "empty"
}
variable "subnet_cidr_block_2" {
  default = "empty"
}
variable "subnet_cidr_block_3" {
  default = "empty"
}
variable "vpc_cidr_block" {}