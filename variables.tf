variable "env" {
  type    = string
  default = "dev"
}

variable "table_name" {
  type = string
  default = "default"
}

variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "myprofile" {
  default = "admin-user"
}