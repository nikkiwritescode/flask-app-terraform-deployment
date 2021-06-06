output "application_endpoint" {
  value = module.network.elb_public_dns
}