resource "vault_mount" "kv_rdp" {
  count       = var.create_kv_mount ? 1 : 0
  path        = var.vault_kv_mount_path   # "kv-rdp"
  type        = "kv"                      # KV v1
  description = "KV v1 for Boundary RDP credentials (flat username/password)"
}

#resource "vault_generic_secret" "rdp_admin" {
#  path = "${var.vault_kv_mount_path}/${var.vault_kv_secret_path}" # kv-rdp/boundary/rdp/svc

#  data_json = jsonencode({
#    username = "Administrator"
#    password = local.admin_password
#  })

#  depends_on = [vault_mount.kv_rdp]
#}













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
