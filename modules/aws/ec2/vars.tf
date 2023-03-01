variable "vpc_name" {
  type = string
}

variable "name" {
  type = string
}

variable "instance_count" {
  type    = string
  default = "1"
}

variable "ami" {
  type = string
}

variable "ami_filter" {
  type    = string
  default = ""
}

variable "associate_public_ip" {
  default = false
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnet_filter" {
  type = string
}

variable "user_data" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(any)
}

variable "sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
}

variable "root_device_size" {
  type    = string
  default = "50"
}

variable "delete_on_termination" {
  default = true
}
