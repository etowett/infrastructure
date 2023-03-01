variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "db_version" {
  type = string
}

variable "db_tier" {
  type = string
}

variable "authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "network_id" {
  type = string
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_host" {
  type    = string
  default = "%"
}

variable "db_password" {
  type = string
}
