output "ami_id" {
    value = data.aws_ami.this.id
}

output "ec2_instance_public_ip" {
    value = aws_instance.this.public_ip
}
