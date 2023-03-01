data "aws_vpc" "peer" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_vpc" "accepter" {
  filter {
    name   = "tag:Name"
    values = [var.accepter_vpc_name]
  }
}

data "aws_route_tables" "peer" {
  vpc_id = data.aws_vpc.peer.id
}

data "aws_route_tables" "accepter" {
  vpc_id = data.aws_vpc.accepter.id
}

resource "aws_route" "accepter" {
  count                     = length(data.aws_route_tables.peer.ids)
  route_table_id            = data.aws_route_tables.peer.ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "peer" {
  count                     = length(data.aws_route_tables.accepter.ids)
  route_table_id            = data.aws_route_tables.accepter.ids[count.index]
  destination_cidr_block    = data.aws_vpc.peer.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = data.aws_vpc.peer.id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true

  tags = {
    Name = var.name
    Side = "Requestor"
  }
}
