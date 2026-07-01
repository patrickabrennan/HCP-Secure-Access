variable "tfc_org" {
  type = string
}

variable "worker_workspace_name" {
  type = string
}

data "terraform_remote_state" "worker" {
  backend = "remote"
  config = {
    organization = var.tfc_org
    workspaces = {
      name = var.worker_workspace_name
    }
  }
}

locals {
  org_scope_id     = data.terraform_remote_state.worker.outputs.org_scope_id
  project_scope_id = data.terraform_remote_state.worker.outputs.project_scope_id

  boundary_discovery_role_arn = data.terraform_remote_state.worker.outputs.boundary_discovery_role_arn

  boundary_db_demo_subnet_id  = data.terraform_remote_state.worker.outputs.boundary_db_demo_subnet_id
  boundary_db_demo_subnet2_id = data.terraform_remote_state.worker.outputs.boundary_db_demo_subnet2_id
  #allow_all_sg_id             = data.terraform_remote_state.worker.outputs.allow_all_sg_id

  #New secure SG output (use this for EC2 + Windows targets)
  boundary_target_sg_id = data.terraform_remote_state.worker.outputs.boundary_target_sg_id
  
  rds_sg_id = data.terraform_remote_state.worker.outputs.rds_sg_id
}

