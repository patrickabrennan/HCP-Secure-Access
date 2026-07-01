terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = ">= 1.3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "boundary" {
  addr                   = var.boundary_addr
  auth_method_id         = var.auth_method_id
  auth_method_login_name = var.password_auth_method_login_name
  auth_method_password   = var.password_auth_method_password
}

resource "random_pet" "unique_names" {}
