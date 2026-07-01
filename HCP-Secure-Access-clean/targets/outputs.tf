#output "rds_endpoint" {
#  value = aws_db_instance.boundary_demo.endpoint
#}


############################################
# EC2 Targets (Windows / Linux)
############################################

#output "windows_instance_id" {
#  description = "Windows target EC2 instance ID"
#  value       = try(aws_instance.windows.id, null)
#}

#output "windows_private_ip" {
#  description = "Windows target private IP"
#  value       = try(aws_instance.windows.private_ip, null)
#}

#output "windows_private_dns" {
#  description = "Windows target private DNS"
#  value       = try(aws_instance.windows.private_dns, null)
#}

#output "linux_instance_id" {
#  description = "Linux target EC2 instance ID"
#  value       = try(aws_instance.ec2.id, null)
#}

#output "linux_private_ip" {
#  description = "Linux target private IP"
#  value       = try(aws_instance.ec2.private_ip, null)
#}

#output "linux_private_dns" {
#  description = "Linux target private DNS"
#  value       = try(aws_instance.ec2.private_dns, null)
#}

############################################
# RDS Target
############################################

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = try(aws_db_instance.boundary_demo.id, null)
}

output "rds_endpoint" {
  description = "RDS endpoint address (host)"
  value       = try(aws_db_instance.boundary_demo.address, null)
}

output "rds_port" {
  description = "RDS port"
  value       = try(aws_db_instance.boundary_demo.port, null)
}

############################################
# Boundary Targets / Host Sets (optional but useful)
############################################

# RDP target (if defined in targets/)
output "boundary_rdp_target_id" {
  description = "Boundary target ID for RDP"
  value       = try(boundary_target.rdp.id, null)
}

# SSH target (if defined in targets/)
#output "boundary_ssh_target_id" {
#  description = "Boundary target ID for SSH"
#  value       = try(boundary_target.ssh.id, null)
#}

# DB target (if defined in targets/)
#output "boundary_db_target_id" {
#  description = "Boundary target ID for DB"
#  value       = try(boundary_target.db.id, null)
#}

# Host sets (if defined in targets/)
output "boundary_rdp_host_set_id" {
  description = "Boundary host set ID for RDP (AWS plugin host set)"
  value       = try(boundary_host_set_plugin.aws_rdp.id, null)
}

#output "boundary_ssh_host_set_id" {
#  description = "Boundary host set ID for SSH (AWS plugin host set)"
#  value       = try(boundary_host_set_plugin.aws_linux.id, null)
#}

############################################
# Convenience: show key Worker outputs used by targets (optional)
############################################
# If you use tfe_outputs in targets, these are handy for debugging.
# Comment these out if you use terraform_remote_state instead or you don't want them.

#output "worker_project_scope_id" {
#  description = "Project scope ID pulled from worker workspace"
#  value       = try(data.tfe_outputs.worker.values.project_scope_id, null)
#}

#output "worker_aws_host_catalog_id" {
#  description = "AWS host catalog plugin ID pulled from worker workspace"
#  value       = try(data.tfe_outputs.worker.values.aws_host_catalog_id, null)
#}

#output "worker_rdp_credential_library_id" {
#  description = "RDP credential library ID pulled from worker workspace"
#  value       = try(data.tfe_outputs.worker.values.rdp_credential_library_id, null)
#}

output "boundary_ssh_target_id" {
  description = "Boundary target ID for SSH"
  value       = try(boundary_target.aws.id, null)
}

output "boundary_db_target_id" {
  description = "Boundary target ID for DB"
  value       = try(boundary_target.dba.id, null)
}

#TMP:
output "boundary_vault_token" {
  value     = vault_token.boundary_vault_token.client_token
  sensitive = true
}

output "boundary_vault_token_policies" {
  value = vault_token.boundary_vault_token.policies
}
