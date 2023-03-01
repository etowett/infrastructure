variable "vpc_name" {
  type        = string
  description = "Name of the requester vpc"
}

variable "name" {
  type        = string
  description = "Name of the peering connection"
}

variable "accepter_vpc_name" {
  type        = string
  description = "Name of the accepter vpc"
}

variable "peer_vpc_id" {
  type        = string
  description = "VPC ID's for Peer Acceptor Accounts"
}
