terraform {
  required_version = ">= 0.15"
  backend "s3" {
    bucket = "application-state-bucket"
    key    = "app/state.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "app" {
  source                = "./modules/app"
  app_name              = var.app_name
  env_prefix            = var.env_prefix
  ami_id                = var.ami_id
  asg_desired_capacity  = var.asg_desired_capacity
  asg_max_size          = var.asg_max_size
  asg_min_size          = var.asg_min_size
  elb_target_group      = module.network.elb_target_group
  instance_type         = var.instance_type
  instance_profile      = module.security.ec2-instance-profile-flask-dynamo-access.name
  internet_gateway      = module.network.gateway
  subnet_ids            = module.network.subnet_ids
  app_security_group_id = module.security.app-sg.id
}

module "network" {
  source                = "./modules/network"
  app_name              = var.app_name
  env_prefix            = var.env_prefix
  vpc_cidr_block        = var.vpc_cidr_block
  subnet_cidr_block_1   = var.subnet_cidr_block_1
  subnet_cidr_block_2   = var.subnet_cidr_block_2
  subnet_cidr_block_3   = var.subnet_cidr_block_3
  elb_security_group_id = module.security.elb-sg.id
  availability_zone_1   = var.avail_zone_1
  availability_zone_2   = var.avail_zone_2
  availability_zone_3   = var.avail_zone_3
}

module "security" {
  source            = "./modules/security"
  app_name          = var.app_name
  dynamo_table_name = module.db.flask_db_table_1.name
  env_prefix        = var.env_prefix
  elb_dns           = module.network.elb_public_dns
  vpc_id            = module.network.vpc.id
}

module "db" {
  source     = "./modules/db"
  app_name   = var.app_name
  env_prefix = var.env_prefix
}