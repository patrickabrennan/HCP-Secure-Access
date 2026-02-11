//Create a periodic, orphan token for Boundary with the attached policies
resource "vault_token" "boundary_vault_token" {
  display_name = "boundary-token"
  #commnet out 9-25-2025
  #policies     = ["boundary-controller", "ssh-policy", "policy-database"]
  #end comment out and add 9-25-2025
  policies = [
    "boundary-controller",
    "ssh-policy",
    "policy-database",
    vault_policy.policy_windows_rdp.name,
  ]
  #end add 9-25-2025
  no_parent    = true
  renewable    = true
  ttl          = "24h"
  period       = "24h"
}

//Credential store for Vault
resource "boundary_credential_store_vault" "vault_cred_store" {
  name        = "boundary-vault-credential-store"
  description = "Vault Credential Store"
  address     = var.vault_addr
  token       = vault_token.boundary_vault_token.client_token
  namespace   = "admin"
  scope_id    = boundary_scope.project.id
  depends_on  = [vault_token.boundary_vault_token]
}

//Credential Library for Brokered DB Credentials
resource "boundary_credential_library_vault" "vault_cred_lib" {
  name                = "boundary-vault-credential-library"
  description         = "Vault DB Credential Brokering"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = "database/creds/dba"
  http_method         = "GET"
}

//Credential library for SSH injected credentials
resource "boundary_credential_library_vault_ssh_certificate" "vault_ssh_cert" {
  name                = "ssh-certs"
  description         = "Vault SSH Cert Library"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = "ssh-client-signer/sign/boundary-client"
  username            = "ec2-user"
}

//Credential store for Boundary
resource "boundary_credential_store_static" "boundary_cred_store" {
  name        = "boundary-credential-store"
  description = "Boundary Credential Store"
  scope_id    = boundary_scope.project.id
}

#commnwr out 9-25-2025
//Static Credentials for Boundary credential store
#resource "boundary_credential_username_password" "rdp_userpass" {
#  credential_store_id = boundary_credential_store_static.boundary_cred_store.id
#  password            = var.rdp_admin_pass
#  username            = var.rdp_admin_username
#
#}
#end commnet out 9-25-2025

# RDP injected credentials from Vault (KV v1 path: kv/boundary/rdp/svc)
resource "boundary_credential_library_vault" "rdp_vault_creds" {
  name                = "rdp-vault-creds"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = var.rdp_vault_creds_path
  http_method         = "GET"
  credential_type     = "username_password"
}

#comment out 1-26-2026
#add 9-25-2025
#resource "boundary_credential_library_vault" "rdp_vault_creds" {
#  name                = "vault-rdp-credential-library"
#  description         = "Dynamic RDP credentials from Vault"
#  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
#  path                = var.rdp_vault_creds_path
#  http_method         = "GET"
#  credential_type     = "username_password"
#}
#end add 9-25-2025
#end comment out



















/*
//Create a periodic, orphan token for Boundary with the attached policies
resource "vault_token" "boundary_vault_token" {
  display_name = "boundary-token"
  #commnet out 9-25-2025
  #policies     = ["boundary-controller", "ssh-policy", "policy-database"]
  #end comment out and add 9-25-2025
  policies = [
    "boundary-controller",
    "ssh-policy",
    "policy-database",
    vault_policy.policy_windows_rdp.name,
  ]
  #end add 9-25-2025
  no_parent    = true
  renewable    = true
  ttl          = "24h"
  period       = "24h"
}

//Credential store for Vault
resource "boundary_credential_store_vault" "vault_cred_store" {
  name        = "boundary-vault-credential-store"
  description = "Vault Credential Store"
  address     = var.vault_addr
  token       = vault_token.boundary_vault_token.client_token
  namespace   = "admin"
  scope_id    = boundary_scope.project.id
  depends_on  = [vault_token.boundary_vault_token]
}

//Credential Library for Brokered DB Credentials
resource "boundary_credential_library_vault" "vault_cred_lib" {
  name                = "boundary-vault-credential-library"
  description         = "Vault DB Credential Brokering"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = "database/creds/dba"
  http_method         = "GET"
}

//Credential library for SSH injected credentials
resource "boundary_credential_library_vault_ssh_certificate" "vault_ssh_cert" {
  name                = "ssh-certs"
  description         = "Vault SSH Cert Library"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = "ssh-client-signer/sign/boundary-client"
  username            = "ec2-user"
}

//Credential store for Boundary
resource "boundary_credential_store_static" "boundary_cred_store" {
  name        = "boundary-credential-store"
  description = "Boundary Credential Store"
  scope_id    = boundary_scope.project.id
}

#commnwr out 9-25-2025
//Static Credentials for Boundary credential store
#resource "boundary_credential_username_password" "rdp_userpass" {
#  credential_store_id = boundary_credential_store_static.boundary_cred_store.id
#  password            = var.rdp_admin_pass
#  username            = var.rdp_admin_username
#
#}
#end commnet out 9-25-2025

resource "boundary_credential_library_vault" "rdp_vault_creds" {
  name                = "rdp-vault-creds"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id    #boundary_credential_store_vault.vault.id
  path                = var.rdp_vault_creds_path
  http_method         = "GET"
  credential_type     = "username_password"

  credential_mapping_overrides = {
    username = "data.data.username"
    password = "data.data.password"
  }
}

#comment out 1-26-2026
#add 9-25-2025
#resource "boundary_credential_library_vault" "rdp_vault_creds" {
#  name                = "vault-rdp-credential-library"
#  description         = "Dynamic RDP credentials from Vault"
#  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
#  path                = var.rdp_vault_creds_path
#  http_method         = "GET"
#  credential_type     = "username_password"
#}
#end add 9-25-2025
#end comment out
*/
