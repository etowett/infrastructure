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
    values = ["*private*"]
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.2"


  cluster_name    = "${var.env}-${var.name}"
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # cluster_encryption_config = [{
  #   provider_key_arn = aws_kms_key.eks.arn
  #   resources        = ["secrets"]
  # }]

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.subnet_ids.ids

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = var.instance_types
    iam_role_attach_cni_policy = true
    desired_size               = var.desired_size
  }

  eks_managed_node_groups = {
    default_node_group = {
      name            = "${var.env}-eks-default-ng"
      use_name_prefix = true

      description = "EKS managed node group for ${var.env}-${var.name}-blue node group"
      subnet_ids  = data.aws_subnets.subnet_ids.ids

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      min_size = var.min_size
      max_size = var.max_size

      disk_size = 50

      capacity_type = "ON_DEMAND"

      update_config = {
        max_unavailable_percentage = var.max_unavailable_percentage
      }

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = var.ssh_key_name
        source_security_group_ids = [aws_security_group.remote_access.id]
      }

      iam_role_use_name_prefix = false
    }

    # blue_ng = {
    #   name            = "${var.env}-${var.name}-blue-ng"
    #   use_name_prefix = true

    #   description = "EKS managed node group for ${var.env}-${var.name}-blue node group"
    #   subnet_ids  = data.aws_subnets.subnet_ids.ids

    #   instance_types = var.blue_instance_types
    #   desired_size   = var.blue_desired_size
    #   min_size       = var.blue_min_size
    #   max_size       = var.blue_max_size

    #   capacity_type = "ON_DEMAND"

    #   disk_size = 50

    #   update_config = {
    #     max_unavailable_percentage = var.max_unavailable_percentage
    #   }

    #   remote_access = {
    #     ec2_ssh_key               = var.ssh_key_name
    #     source_security_group_ids = [aws_security_group.remote_access.id]
    #   }

    #   iam_role_use_name_prefix = false
    # }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_allow_all = {
      description                   = "Cluster to node allow all"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  tags = var.tags
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_security_group" "remote_access" {
  name        = "${var.env}-${var.name}-ssh-access"
  description = "Allow SSH Access to EKS ${var.env}-${var.name} nodes"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description      = "SSH From Everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
