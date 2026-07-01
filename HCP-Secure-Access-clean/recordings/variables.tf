variable "tfc_org" {
  type = string
}

variable "worker_workspace_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "boundary_addr" {
  type = string
}

variable "auth_method_id" {
  type = string
}

variable "password_auth_method_login_name" {
  type = string
}

variable "password_auth_method_password" {
  type      = string
  sensitive = true
}
