# Declare the required providers and their version constraints for this Terraform configuration
terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = ">= 1.3.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.2.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.2"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">=0.56.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
    #PB added 7/25/2024
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.46.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
    #PB end 7/25/2024
  }
}

# Declare the provider for the AWS resource to be managed by Terraform
#PB commented out 7/25/2024
provider "aws" {
  region = "us-east-1"
}

#provider "vault" {
#}

provider "vault" {
  // skip_child_token must be explicitly set to true as HCP Terraform manages the token lifecycle
  skip_child_token = true
  address          = var.tfc_vault_dynamic_credentials.default.address
  namespace        = var.tfc_vault_dynamic_credentials.default.namespace

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.default.token_filename
  }
}

provider "vault" {
  // skip_child_token must be explicitly set to true as HCP Terraform manages the token lifecycle
  skip_child_token = true
  alias            = "ALIAS1"
  address          = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].address
  namespace        = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].namespace

  auth_login_token_file {
    filename = var.tfc_vault_dynamic_credentials.aliases["ALIAS1"].token_filename
  }
}






# Declare the provider for the HashiCorp Boundary resource to be managed by Terraform
provider "boundary" {
  # Use variables to provide values for the provider configuration
  addr                   = var.boundary_addr
  auth_method_login_name = var.password_auth_method_login_name
  auth_method_password   = var.password_auth_method_password
}

resource "random_pet" "unique_names" {
}

#PB added 7/25/2024
#provider "aws" {}
provider "time" {}


