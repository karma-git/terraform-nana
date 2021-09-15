module "my-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs            = [var.av_zone]
  public_subnets = [var.sunbet_cidr_block]

  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "my-webserver" {
  source = "../_modules/webserver"

  vpc_id           = module.my-vpc.vpc_id
  subnet_id        = module.my-vpc.public_subnets[0]
  my_ip            = var.my_ip
  env_prefix       = var.env_prefix
  public_key_path  = var.public_key_path
  instance_type    = var.instance_type
  av_zone          = var.av_zone
  ssh_user         = var.ssh_user
  private_key_path = var.private_key_path
}
