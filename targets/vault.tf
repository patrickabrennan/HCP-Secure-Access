resource "vault_mount" "kv_rdp" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path
  type        = "kv"
  description = "KV v1 for Boundary RDP credentials (flat username/password)"

  options = {
    version = "1"
  }
}

#commented out 6/30/2026
#resource "vault_generic_secret" "rdp_admin" {
#  path = "${var.vault_kv_mount_path}/${var.vault_kv_secret_path}"
#
#  data_json = jsonencode({
#    username = "Administrator"
#    password = trimspace(local.admin_password)
#  })
#
#  depends_on = [vault_mount.kv_rdp]
#}

#added 6/30/2026
resource "boundary_credential_library_vault" "rdp_vault_creds" {
  name                = "rdp-vault-creds"
  credential_store_id = boundary_credential_store_vault.vault_cred_store.id
  path                = var.rdp_vault_creds_path
  http_method         = "GET"

  credential_type = "username_password_domain"
}







/*
resource "vault_mount" "kv_rdp" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path   # "kv-rdp"
  type        = "kv"                      # KV v1
  description = "KV v1 for Boundary RDP credentials (flat username/password)"
}

resource "vault_generic_secret" "rdp_admin" {
  path = "${var.vault_kv_mount_path}/${var.vault_kv_secret_path}" # kv-rdp/boundary/rdp/svc

  data_json = jsonencode({
    username = "Administrator"
    password = local.admin_password
  })

  depends_on = [vault_mount.kv_rdp]
}
*/












/*
# Create a dedicated KV v1 mount just for Boundary RDP injection.
# This avoids fighting with an existing "kv" mount that is likely KV v2 in HCP Vault.

resource "vault_mount" "kv_rdp" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path         # set to "kv-rdp"
  type        = "kv"                            # KV v1
  description = "KV v1 for Boundary RDP credentials (flat username/password)"
}

# Write a flat secret (no nested data.data like KV v2)
resource "vault_generic_secret" "rdp_admin" {
  path = "${var.vault_kv_mount_path}/${var.vault_kv_secret_path}" # kv-rdp/boundary/rdp/svc

  data_json = jsonencode({
    username = "Administrator"
    password = local.admin_password
  })
}
*/
