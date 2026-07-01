data "terraform_remote_state" "worker" {
  backend = "remote"

  config = {
    organization = var.tfc_org

    workspaces = {
      name = var.worker_workspace_name
    }
  }
}
