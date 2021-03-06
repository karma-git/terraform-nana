provider "aws" {
  region  = "us-east-2"
  profile = "karma-it-aws"
}

variable "vpc_cidr_block" {}
variable "sunbet_cidr_block" {}
variable "av_zone" {}
variable "env_prefix" {}
// export TF_VAR_my_ip=$(curl --silent ifconfig.me.)
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_path" {}
variable "private_key_path" {}
variable "ssh_user" {}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "this" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.sunbet_cidr_blok
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
  subnet_id      = aws_subnet.this.id
}


resource "aws_security_group" "this" {
  name   = "webserver-sg"
  vpc_id = aws_vpc.this.id

  // incoming traffic
  ingress {
    /*
        range from port to port (for example 0 to 1000)
        */
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    // see variables
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    // web
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outgoing traffic
  egress {
    // Allow outgoing traffic from all ports
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}
// !NOTE we can use default sg created with vpc via resource <aws_default_security_group>

/*
aws amazon linux ami

data "aws_ami" "this" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
*/

data "aws_ami" "this" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "description"
    values = ["Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.this.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.this.public_ip
}

resource "aws_key_pair" "this" {
  key_name   = "webserver-key"
  public_key = file(var.public_key_path)
  // public_key = file(...) ~/.ssh/id_rsa
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.this.id
  vpc_security_group_ids = [aws_security_group.this.id]
  availability_zone      = var.av_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name

  // user_data = file("../scripts/install_docker_engine.sh")

  provisioner "remote-exec" {
    script = "../scripts/wait_for_instance.sh"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = var.ssh_user
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = <<EOF
        ansible-playbook \
          --inventory '${self.public_ip},' \
          --private-key ${var.private_key_path} \
          --user ${var.ssh_user} \
          ../ansible/playbook.yml
        EOF

  }

  tags = {
    Name = "${var.env_prefix}-webserver"
  }
}
