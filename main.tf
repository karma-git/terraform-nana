provider "aws" {
    region = "us-east-2"
    profile = "karma-it-aws"
}

resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name: "development"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "us-east-2a"
    tags = {
        Name: "subnet-1-dev"
    }
}
