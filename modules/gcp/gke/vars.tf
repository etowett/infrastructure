variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "initial_node_count" {
  type    = number
  default = 1
}

variable "machine_type" {
  type = string
  # default = "c2-standard-4"
}

variable "network_name" {
  type = string
}

variable "public_subnet_name" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "disk_size_gb" {
  type = number
  default = 25
}
