resource "vault_mount" "kv_rdp" {
  count = var.create_kv_mount ? 1 : 0

  path = var.vault_kv_mount_path
  type = "kv"

  options = {
    version = "1"
  }
}

#Add 7/1/2026
resource "vault_generic_secret" "rdp_admin" {
  path = "${var.vault_kv_mount_path}/${var.vault_kv_secret_path}"

  data_json = jsonencode({
    username = "Administrator"
    password = trimspace(local.admin_password)
  })

  depends_on = [
    vault_mount.kv_rdp
  ]
}
