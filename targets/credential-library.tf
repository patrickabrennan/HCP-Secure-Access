//Create a periodic, orphan token for Boundary with the attached policies
resource "vault_token" "boundary_vault_token" {
  display_name = "boundary-token"

  policies = [
    vault_policy.boundary_controller_policy.name,
    vault_policy.ssh-policy.name,
    vault_policy.policy-database.name,
    vault_policy.policy_windows_rdp.name,
  ]

  no_parent = true
  renewable = true
  ttl       = "24h"
  period    = "24h"

  depends_on = [
    vault_policy.boundary_controller_policy,
    vault_policy.ssh-policy,
    vault_policy.policy-database,
    vault_policy.policy_windows_rdp,
  ]
}

//Credential store for Vault
resource "boundary_credential_store_vault" "vault_cred_store" {
  name        = "boundary-vault-credential-store"
  description = "Vault Credential Store"
  address     = var.vault_addr
  token       = vault_token.boundary_vault_token.client_token
  namespace   = "admin"
  scope_id    = local.project_scope_id

  depends_on = [vault_token.boundary_vault_token]
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
  scope_id    = local.project_scope_id
}

#Added 7/1/2026 - back to no domain
resource "boundary_credential_library_vault" "rdp_vault_creds" {
  name                = "rdp-vault-creds"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = var.rdp_vault_creds_path
  http_method         = "GET"

  credential_type = "username_password"
}
