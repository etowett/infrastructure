output "instance_id" {
  value = module.ec2-instance.*.id
}

output "private_ip" {
  value = module.ec2-instance.*.private_ip
}

output "public_ip" {
  value = module.ec2-instance.*.public_ip
}

output "tags_all" {
  value = module.ec2-instance.*.tags_all
}

output "public_dns" {
  value = module.ec2-instance.*.public_dns
}

output "private_dns" {
  value = module.ec2-instance.*.private_dns
}
