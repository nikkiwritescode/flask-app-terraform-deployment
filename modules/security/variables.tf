variable "app_name" {}
variable "build_env" {}
variable "dynamo_table_name" {}
variable "env_prefix" {}
variable "elb_dns" {}
variable "my_public_key_location" {
    default = "~/.ssh/id_rsa.pub"
}
variable "my_public_key" {
    default = "empty"
}
variable "my_ip" {}
variable "vpc_id" {}