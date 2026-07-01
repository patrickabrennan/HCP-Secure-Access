variable "recordings_workspace_name" {
  type = string
}

data "terraform_remote_state" "recordings" {
  backend = "remote"

  config = {
    organization = var.tfc_org

    workspaces = {
      name = var.recordings_workspace_name
    }
  }
}
