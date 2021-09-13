provider "aws" {
    region = "us-east-2"
    profile = "karma-it-aws"
}

variable vpc_cidr_block {}
variable sunbet_cidr_blok {}
variable av_zone {}
variable env_prefix {}

resource "aws_vpc" "app" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "app" {
    vpc_id = aws_vpc.app.id
    cidr_block = var.sunbet_cidr_blok
    availability_zone = var.av_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "app" {
    vpc_id = aws_vpc.app.id

    routes {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app.id
    }

    tags {
        Name = "${var.env_prefix}-route-table"
    }
}

resource "aws_route_table_association" "app" {
    route_table_id = aws_default_route_table.app.id
    subnet_id = aws_subnet.app.id
}
