provider "aws" {
  region = "us-east-2"
}

module "app" {
  source                = "./modules/app"
  app_name              = var.app_name
  env_prefix            = var.env_prefix
  dynamo_table          = module.db.flask_db_table_1
  git_username          = var.git_username
  git_token             = var.git_token
  instance_type         = var.instance_type
  instance_profile      = module.security.ec2-instance-profile-flask-dynamo-access.name
  avail_zone_1          = var.avail_zone_1
  avail_zone_2          = var.avail_zone_2
  subnet_1_id           = module.network.subnet-1.id
  subnet_2_id           = module.network.subnet-2.id
  app_security_group_id = module.security.app-sg.id
  key_pair_name         = module.security.key-pair-name
}

module "network" {
  source                = "./modules/network"
  app_name              = var.app_name
  env_prefix            = var.env_prefix
  vpc_cidr_block        = var.vpc_cidr_block
  subnet_cidr_block_1   = var.subnet_cidr_block_1
  subnet_cidr_block_2   = var.subnet_cidr_block_2
  elb_security_group_id = module.security.elb-sg.id
  avail_zone_1          = var.avail_zone_1
  avail_zone_2          = var.avail_zone_2
  instance_id_1         = module.app.instance-1.id
  instance_id_2         = module.app.instance-2.id
}

module "security" {
  source                 = "./modules/security"
  app_name               = var.app_name
  env_prefix             = var.env_prefix
  git_token              = var.git_token
  dynamo_table_name      = module.db.flask_db_table_1.name
  my_ip                  = var.my_ip
  elb_dns                = module.network.elb_public_dns
  my_public_key_location = var.my_public_key_location
  secret_name            = var.secret_name
  vpc_id                 = module.network.vpc.id
}

module "db" {
  source     = "./modules/db"
  app_name   = var.app_name
  env_prefix = var.env_prefix
}