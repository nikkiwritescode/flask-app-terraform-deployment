variable "app_name" {}
variable "env_prefix" {}
variable "dynamo_table" {}
variable "git_username" {
    sensitive = true
}
variable "git_token" {
    sensitive = true
}
variable "instance_type" {}
variable "instance_profile" {}
variable "avail_zone_1" {}
variable "avail_zone_2" {}
variable "subnet_1_id" {}
variable "subnet_2_id" {}
variable "app_security_group_id" {}
variable "key_pair_name" {}