#Boundary config for the Postgres DB target
resource "boundary_host_catalog_static" "db_host_catalog" {
  #scope_id = boundary_scope.project.id
  scope_id = local.project_scope_id
}

resource "boundary_host_static" "postgres_host" {
  type            = "static"
  name            = "Postgres Host"
  address         = aws_db_instance.boundary_demo.address
  host_catalog_id = boundary_host_catalog_static.db_host_catalog.id
}

resource "boundary_host_set_static" "db_static_host_set" {
  name            = "Postgres Static Host Set"
  host_catalog_id = boundary_host_catalog_static.db_host_catalog.id
  host_ids        = [boundary_host_static.postgres_host.id]
}

resource "boundary_target" "dba" {
  type                     = "tcp"
  name                     = "aws-rds"
  description              = "AWS RDS Target"
  egress_worker_filter     = " \"self-managed-aws-worker\" in \"/tags/type\" "
#  scope_id                 = boundary_scope.project.id
  scope_id = local.project_scope_id

  session_connection_limit = 3600
  default_port             = 5432
  host_source_ids = [
    boundary_host_set_static.db_static_host_set.id
  ]

  #added ingress worker filter 2/26/2026
  ingress_worker_filter = "\"self-managed-aws-worker\" in \"/tags/type\""

  brokered_credential_source_ids = [
    boundary_credential_library_vault.vault_cred_lib.id
  ]
}
