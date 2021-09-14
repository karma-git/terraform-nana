resource "aws_security_group" "this" {
    name = "webserver-sg"
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.my_ip}/32"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
}


data "aws_ami" "this" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "description"
        values = ["Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "this" {
    key_name = "webserver-key"
    public_key = file(var.public_key_path)
}

resource "aws_instance" "this" {
    ami = data.aws_ami.this.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.this.id]
    availability_zone = var.av_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.this.key_name
    
    tags = {
        Name = "${var.env_prefix}-webserver"
    }
}
