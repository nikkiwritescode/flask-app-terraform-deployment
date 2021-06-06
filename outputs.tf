output "instance_1_public_ip" {
  value = module.app.instance-1.public_ip
}
output "instance_2_public_ip" {
  value = module.app.instance-2.public_ip
}
output "elb_public_dns" {
  value = module.network.elb_public_dns
}