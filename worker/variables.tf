variable "tfc_vault_dynamic_credentials" {
  description = "Object containing Vault dynamic credentials configuration"
  type = object({
    default = object({
      token_filename = string
      address        = string
      namespace      = string
      ca_cert_file   = string
    })
    aliases = map(object({
      token_filename = string
      address        = string
      namespace      = string
      ca_cert_file   = string
    }))
  })
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "availability_zone2" {
  type    = string
  default = "us-east-1b"
}

variable "aws_ami" {
  type        = string
  description = "Optional override for AMI. If empty, the Windows data source is used."
  default     = ""
}

variable "aws_instance_type" {
  type    = string
  default = "t3.large"
}

variable "admin_key_name" {
  description = "Existing EC2 Key Pair name (public key already in AWS)."
  type        = string
  default     = ""
}

variable "aws_vpc_cidr" {
  type    = string
  default = "172.40.0.0/16"
}

variable "aws_subnet_cidr" {
  type    = string
  default = "172.40.10.0/24"
}

variable "aws_subnet_cidr2" {
  type    = string
  default = "172.40.20.0/24"
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

variable "vault_addr" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_name_tags" {
  type    = string
  default = "session-recording"
}

variable "s3_bucket_env_tags" {
  type    = string
  default = "boundary"
}

variable "rdp_vault_creds_path" {
  type        = string
  description = <<-EOT
    Vault path that returns a {username,password} pair for Windows/RDP.
    Examples:
      - "kv/data/boundary/rdp/svc"   (KV v2 secret path)
      - "ad/creds/boundary-rdp"     (Vault Active Directory secrets engine role)
      - "windows/creds/boundary-rdp" (Vault Windows secrets engine role)
  EOT
}

variable "admin_key_private_pem" {
  description = "PEM contents of the private key matching the EC2 key pair (not a path)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_kv_mount" { 
  type = bool 
  default = false
}

variable "vault_kv_mount_path" { 
  type = string
  default = "kv" 
}

variable "vault_kv_secret_path" {
  type = string 
  default = "boundary/rdp/svc"
}

variable "decrypted_admin_password" {
  type        = string
  sensitive   = true
  default     = ""   # keeps destroy safe even if you don't pass it
}



















/*
variable "tfc_vault_dynamic_credentials" {
  description = "Object containing Vault dynamic credentials configuration"
  type = object({
    default = object({
      token_filename = string
      address = string
      namespace = string
      ca_cert_file = string
    })
    aliases = map(object({
      token_filename = string
      address = string
      namespace = string
      ca_cert_file = string
    }))
  })
}

variable "boundary_addr" {
  type = string
}

variable auth_method_id {
  type = string
}

variable "password_auth_method_login_name" {
  type = string
}

variable "password_auth_method_password" {
  type = string
}

#variable "aws_access" {
#  type = string
#}

#variable "aws_secret" {
#  type = string
#}

variable "aws_ami" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_vpc_cidr" {
  type        = string
  description = "The AWS Region CIDR range to assign to the VPC"
}

variable "aws_subnet_cidr" {
  type = string
}

variable "aws_subnet_cidr2" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "availability_zone2" {
  description = "Second AZ for RDS deployment"
  type        = string
}

variable "vault_addr" {
  type = string
}

#variable "vault_token" {
#  type = string
#}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type    = string
  default = "boundarydemo"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_bucket_name_tags" {
  type        = string
  description = "Name tag to associate to the S3 Bucket"
  default     = "session-recording"
}

variable "s3_bucket_env_tags" {
  type        = string
  description = "Environment tag to associate to the S3 Bucket"
  default     = "boundary"
}

#variable "rdp_admin_pass" {
#  type        = string
#  description = "The password to set on the windows target for the admin user"
#}

variable "rdp_admin_username" {
  type        = string
  description = "The admin username for RDP target"
  default     = "Admin"
}


#Added 9-25-2025
variable "rdp_vault_creds_path" {
  type        = string
  description = <<-EOT
    Vault path that returns a {username,password} pair for Windows/RDP.
    Examples:
      - "ad/creds/boundary-rdp"     (Vault Active Directory secrets engine role)
      - "windows/creds/boundary-rdp" (Vault Windows secrets engine role)
  EOT
}

variable "admin_key_private_pem" {
  description = "PEM contents of the private key matching the EC2 key pair (not a path)."
  type        = string
  sensitive   = true
}

variable "create_kv_mount" { 
  type = bool 
  default = false
}

variable "vault_kv_mount_path" { 
  type = string
  default = "kv" 
}

variable "vault_kv_secret_path" {
  type = string 
  default = "boundary/rdp/svc"
}

variable "decrypted_admin_password" {
  type        = string
  sensitive   = true
  default     = ""   # keeps destroy safe even if you don't pass it
}
*/
