data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.prefix.environment}-${var.prefix.name}-vpc"
  cidr = var.vpc.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc.private_subnets
  public_subnets  = var.vpc.public_subnets

  enable_nat_gateway = var.vpc.enable_nat_gateway
  single_nat_gateway = var.vpc.single_nat_gateway

  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support

  tags = { "Name" = "${var.prefix.environment}-${var.prefix.name}-vpc" }
}
