variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "tier" {
  type    = string
  default = "BASIC"
}

variable "memory_size_gb" {
  type    = number
  default = 1
}

variable "redis_version" {
  type    = string
  default = "REDIS_6_X"
}
