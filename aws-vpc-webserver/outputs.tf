output "ami_id" {
  value = module.my-webserver.aws_ami.id
}

output "ec2_instance_public_ip" {
  value = module.my-webserver.ec2_instance.public_ip
}
