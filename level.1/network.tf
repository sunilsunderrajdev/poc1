data "aws_availability_zones" "available" {
    state = "available"
}

module "vpc" {
    source              = "terraform-aws-modules/vpc/aws"
    name                = "main-vpc"
    cidr                = var.vpc_cidr
    azs                 = data.aws_availability_zones.available.names[*]
    private_subnets     = var.private_subnets
    public_subnets      = var.public_subnets
    enable_nat_gateway  = true
}
