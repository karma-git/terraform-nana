resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "my-vpc" {
    source = "../_modules/vpc"

    sunbet_cidr_block = var.sunbet_cidr_block
    av_zone = var.av_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.this.id
    default_route_table_id = aws_vpc.this.default_route_table_id
}

module "my-webserver" {
    source = "../_modules/webserver"

    vpc_id = aws_vpc.this.id
    subnet_id = module.my-vpc.subnet.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    public_key_path = var.public_key_path
    instance_type = var.instance_type
    av_zone = var.av_zone
    ssh_user = var.ssh_user
    private_key_path = var.private_key_path
}
