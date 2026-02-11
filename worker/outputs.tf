############################################
# Boundary scope outputs
############################################

output "project_scope_id" {
  description = "Boundary project scope ID used by targets workspace"
  value       = boundary_scope.project.id
}

############################################
# Boundary AWS host catalog (plugin)
############################################

#output "aws_host_catalog_id" {
#  description = "Boundary AWS host catalog plugin ID"
#  value       = boundary_host_catalog_plugin.aws_plugin.id
#}

############################################
# Boundary Vault credential libraries
############################################

output "rdp_credential_library_id" {
  description = "Boundary Vault credential library for Windows RDP injection"
  value       = boundary_credential_library_vault.rdp_vault_creds.id
}

# Optional: expose SSH or DB credential libraries if targets need them
# output "ssh_credential_library_id" {
#   value = boundary_credential_library_vault.ssh_vault_creds.id
# }

# output "db_credential_library_id" {
#   value = boundary_credential_library_vault.db_vault_creds.id
# }

############################################
# AWS networking outputs
############################################

#output "vpc_id" {
#  description = "VPC ID used by Boundary targets"
#  value       = aws_vpc.main.id
#}

#output "public_subnet_ids" {
#  description = "Public subnet IDs for target instances"
#  value       = aws_subnet.public[*].id
#}

# Optional if you also have private targets
# output "private_subnet_ids" {
#   value = aws_subnet.private[*].id
# }

############################################
# Shared Security Groups
############################################

#output "target_instance_sg_id" {
#  description = "Security group ID shared by Boundary-managed target instances"
#  value       = aws_security_group.boundary_target.id
#}

# Optional: worker SG if targets need to reference it
# output "boundary_worker_sg_id" {
#   value = aws_security_group.boundary_worker.id
# }

