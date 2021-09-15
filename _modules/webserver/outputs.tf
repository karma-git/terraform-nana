output "aws_ami" {
  value = data.aws_ami.this
}

output "ec2_instance" {
  value = aws_instance.this
}
