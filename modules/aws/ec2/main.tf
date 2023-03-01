locals {
  subnet_ids_list         = tolist(data.aws_subnets.subnet_ids.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnets.subnet_ids.ids)
  instance_subnet_id      = local.subnet_ids_list[local.subnet_ids_random_index]
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.subnet_filter}*"]
  }
}

resource "random_id" "index" {
  byte_length = 2
}

# data "aws_ami" "ami" {
#   most_recent = true
#   owners      = ["self"]

#   filter {
#     name   = "name"
#     values = ["${var.ami_filter}-*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

module "ec2-instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "4.1.1"
  name                        = var.name
  count                       = var.instance_count
  ami                         = var.ami
  associate_public_ip_address = var.associate_public_ip
  disable_api_termination     = false
  instance_type               = var.instance_type
  key_name                    = var.key_name
  user_data                   = var.user_data
  monitoring                  = true
  subnet_id                   = local.instance_subnet_id

  vpc_security_group_ids = [
    aws_security_group.ec2-instance-sg.id
  ]

  root_block_device = [
    {
      volume_size           = var.root_device_size
      volume_type           = "gp2"
      delete_on_termination = var.delete_on_termination
    },
  ]

  tags = var.tags
}

resource "aws_security_group_rule" "sg_rules" {
  count = length(var.sg_rules)

  type              = var.sg_rules[count.index].type
  from_port         = var.sg_rules[count.index].from_port
  to_port           = var.sg_rules[count.index].to_port
  protocol          = var.sg_rules[count.index].protocol
  cidr_blocks       = [var.sg_rules[count.index].cidr_block]
  description       = var.sg_rules[count.index].description
  security_group_id = aws_security_group.ec2-instance-sg.id
}

resource "aws_security_group" "ec2-instance-sg" {
  name        = "${var.name}_sg"
  description = "${var.name} SG "
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name = "${var.name}_sg"
  }
}
