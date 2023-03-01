variable "env" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_name" {
  type = string
}

variable "identifier" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "username" {
  type    = string
  default = "root"
}

variable "port" {
  type = string
}

variable "allocated_storage" {
  type = string
}

variable "max_allocated_storage" {
  type = string
}

variable "maintenance_window" {
  type    = string
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type    = string
  default = "03:00-06:00"
}

variable "monitoring_interval" {
  type    = string
  default = "30"
}

variable "create_monitoring_role" {
  default = true
}

variable "parameter_group_name" {
  type    = string
  default = ""
}

variable "create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  default     = true
}

variable "family" {
  type = string
}

variable "major_engine_version" {
  type = string
}

variable "deletion_protection" {
  default = true
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "parameters" {
  type    = list(any)
  default = []
}

variable "options" {
  type    = list(any)
  default = []
}

variable "password_length" {
  type    = string
  default = "40"
}

variable "password_special" {
  type    = bool
  default = false
}

variable "secret_name" {
  description = "Specifies the friendly name of the new secret."
  type        = string
}

variable "postgres_clients" {
  type    = list(string)
  default = []
}
