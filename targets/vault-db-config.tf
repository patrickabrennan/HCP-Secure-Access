resource "vault_mount" "postgres_database" {
  path        = "database"
  type        = "database"
  description = "Postgres DB Engine"

  default_lease_ttl_seconds = 600
  max_lease_ttl_seconds     = 600
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend           = vault_mount.postgres_database.path
  name              = "demo-postgres"
  allowed_roles     = ["*"]
  verify_connection = false
  postgresql {
    connection_url       = "postgresql://{{username}}:{{password}}@${aws_db_instance.boundary_demo.endpoint}/${var.db_name}?sslmode=disable"
    username             = var.db_username
    password             = var.db_password
    max_open_connections = 5
  }
}
resource "vault_database_secret_backend_role" "dba" {
  backend = vault_mount.postgres_database.path
  name    = "dba"
  db_name = vault_database_secret_backend_connection.postgres.name
  creation_statements = [
    "CREATE USER \"{{name}}\" WITH LOGIN ENCRYPTED PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT rds_superuser to \"{{name}}\"",
    "GRANT CONNECT ON DATABASE ${var.db_name} TO \"{{name}}\";",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";",
    "ALTER ROLE \"{{name}}\" WITH CREATEDB CREATEROLE;",
  ]
  revocation_statements = [
    "GRANT \"{{name}}\" to \"${var.db_username}\";",
    "REVOKE ALL ON ALL TABLES IN SCHEMA public FROM \"{{name}}\";",
    "REVOKE ALL ON DATABASE ${var.db_name} FROM \"{{name}}\";",
    "REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM \"{{name}}\";",
    "REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM \"{{name}}\";",
    "REASSIGN OWNED BY \"{{name}}\" to \"${var.db_username}\";",
    "DROP OWNED BY \"{{name}}\";",
    "DROP ROLE IF EXISTS \"{{name}}\";"
  ]
  default_ttl = 600
  max_ttl     = 600
}
