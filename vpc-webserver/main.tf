provider "aws" {
    region = "us-east-2"
    profile = "karma-it-aws"
}

variable vpc_cidr_block {}
variable sunbet_cidr_blok {}
variable av_zone {}
variable env_prefix {}
// export TF_VAR_my_ip=$(curl --silent ifconfig.me.)
variable my_ip {}

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "this" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.sunbet_cidr_blok
    availability_zone = var.av_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

/*

We can use default route table as well

resource "aws_route_table" "this" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
        Name = "${var.env_prefix}-route-table"
    }
}

resource "aws_route_table_association" "this" {
    route_table_id = aws_route_table.this.id
    subnet_id = aws_subnet.this.id
}
 */

resource "aws_default_route_table" "this" {
    default_route_table_id = aws_vpc.this.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
        Name = "${var.env_prefix}-route-table"
    }
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_default_route_table.this.id
  subnet_id = aws_subnet.this.id
}

resource "aws_security_group" "this" {
    name = "webserver-sg"
    vpc_id = aws_vpc.this.id

    // incoming traffic
    ingress {
        /*
        range from port to port (for example 0 to 1000)
        */
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // see variables
        cidr_blocks = ["${var.my_ip}/32"]
    }

    ingress {
        // web
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # outgoing traffic
    egress {
        // Allow outgoing traffic from all ports
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
}
