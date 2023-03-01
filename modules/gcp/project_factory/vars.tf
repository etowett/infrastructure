variable "stage" {
  type        = string
  description = "Stage"
}

variable "name" {
  type        = string
  description = "Project name that will be used as an identifier"
}

variable "region" {
  type        = string
  description = "Resource region"
  default     = "europe-west-1"
}

variable "location" {
  type        = string
  description = "Resource location"
  default     = "EU"
}

variable "billing_account" {
  type    = string
  default = "011116-019C48-D5A515"
}

variable "user_email" {
  type    = string
  default = "smithzx90@gmail.com"
}
