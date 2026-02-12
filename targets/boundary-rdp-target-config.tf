resource "boundary_host_set_plugin" "aws_rdp" {
  name                  = "AWS Windows Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:Name=rdp-target" })
  sync_interval_seconds = 30
}

#add 9-25-2025
resource "boundary_target" "rdp" {
  type                     = "rdp"   # was: "tcp"
  name                     = "aws-windows"
  description              = "AWS Windows Target"
  egress_worker_filter     = " \"self-managed-aws-worker\" in \"/tags/type\" "
  #scope_id                 = boundary_scope.project.id
  scope_id                 = local.project_scope_id
  #session_connection_limit = 1
  default_port             = 3389
  default_client_port      = 3389
  host_source_ids          = [boundary_host_set_plugin.aws_rdp.id]

  # ADD this for RDP credential injection:
  # Inject dynamic RDP creds from Vault into the session:
  injected_application_credential_source_ids = [
    boundary_credential_library_vault.rdp_vault_creds.id
  ]
}
