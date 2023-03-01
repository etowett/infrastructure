variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "cidr" {
  type = string
}

variable "enable_nat_gateway" {
  type = bool
}

variable "enable_vpn_gateway" {
  type = bool
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_dhcp_options" {
  type    = bool
  default = true
}

variable "one_nat_gateway_per_az" {
  type    = bool
  default = false
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type    = list(string)
  default = []
}

variable "elasticache_subnets" {
  type    = list(string)
  default = []
}

variable "reuse_nat_ips" {
  type    = bool
  default = true
}

variable "create_database_subnet_group" {
  type    = bool
  default = false
}

variable "create_database_subnet_route_table" {
  type    = bool
  default = false
}

variable "create_database_internet_gateway_route" {
  type    = bool
  default = false
}

variable "create_database_nat_gateway_route" {
  type    = bool
  default = false
}

variable "enable_dns_support" {
  type = bool
}
