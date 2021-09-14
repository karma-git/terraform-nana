/*
https://stackoverflow.com/questions/55449909/error-while-configuring-terraform-s3-backend
When running the terraform init you have to add -backend-config options for your credentials (aws keys)

$ terraform init \
  -backend-config="access_key"=$AWS_ACCESS_KEY_ID \  
  -backend-config="secret_key"=$AWS_SECRET_ACCESS_KEY
*/

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "nana-terraform"
    key = "nana-terraform/state.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
    region = "us-east-2"
    profile = "karma-it-aws"
}

resource "aws_instance" "this" {
  ami = "ami-00dfe2c7ce89a450b"
  instance_type = "t2.micro"
}
