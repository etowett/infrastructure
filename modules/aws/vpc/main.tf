resource "aws_eip" "nat" {
  vpc = true
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.1"

  name = var.name
  cidr = var.cidr

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  database_subnets    = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  reuse_nat_ips       = var.reuse_nat_ips
  external_nat_ip_ids = [aws_eip.nat.id]

  create_database_subnet_group           = var.create_database_subnet_group
  create_database_subnet_route_table     = var.create_database_subnet_route_table
  create_database_internet_gateway_route = var.create_database_internet_gateway_route
  create_database_nat_gateway_route      = var.create_database_nat_gateway_route
  enable_dns_hostnames                   = var.enable_dns_hostnames
  enable_dns_support                     = var.enable_dns_support
  single_nat_gateway                     = var.single_nat_gateway
  enable_dhcp_options                    = var.enable_dhcp_options
  one_nat_gateway_per_az                 = var.one_nat_gateway_per_az
}
