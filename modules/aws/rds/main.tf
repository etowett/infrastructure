data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "database_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-db-*"]
  }
}

resource "random_password" "password" {
  length           = var.password_length
  special          = var.password_special
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "secret" {
  name        = var.secret_name
  description = "DevOps Root Credentials For ${var.identifier}"
}

resource "aws_secretsmanager_secret_version" "rds_default_user_credentials" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = <<EOF
{
  "username": "${var.username}",
  "password": "${random_password.password.result}"
}
EOF
}

data "aws_secretsmanager_secret_version" "arn" {
  secret_id = aws_secretsmanager_secret_version.rds_default_user_credentials.arn
}

data "external" "password_retrival_helper" {
  program = ["bash", "${path.module}/scripts/rds_password.sh"]

  query = {
    devops_secret_arn = aws_secretsmanager_secret_version.rds_default_user_credentials.arn
    aws_region        = var.aws_region
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.0.3"

  identifier = var.identifier

  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name  = var.db_name
  username = var.username
  password = data.external.password_retrival_helper.result["password"]
  port     = var.port

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db.id]

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  monitoring_interval    = var.monitoring_interval
  monitoring_role_name   = var.identifier
  create_monitoring_role = var.create_monitoring_role

  parameter_group_name = var.parameter_group_name

  skip_final_snapshot = var.skip_final_snapshot

  tags = {
    Env = var.env
  }

  # DB subnet group
  create_db_subnet_group = var.create_db_subnet_group
  subnet_ids             = data.aws_subnets.database_subnet.ids

  # DB parameter group
  family = var.family

  # DB option group
  major_engine_version = var.major_engine_version

  # Database Deletion Protection
  deletion_protection = var.deletion_protection

  parameters = var.parameters
  options    = var.options
}

resource "aws_security_group" "db" {
  name        = "${var.identifier}_security_group"
  description = "Allow all inbound traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "Postgres Default Port"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.postgres_clients
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
