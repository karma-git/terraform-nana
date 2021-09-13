resource "aws_subnet" "this" {
    vpc_id = var.vpc_id
    cidr_block = var.sunbet_cidr_block
    availability_zone = var.av_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "this" {
    default_route_table_id = var.default_route_table_id

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
