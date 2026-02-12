#PB added 7/25/2024
# Example below heavily lifted from:
# https://registry.terraform.io/providers/hashicorp/boundary/latest/docs/resources/host_catalog_plugin

############################################
# Boundary AWS Host Catalog (Plugin-based)
############################################

resource "boundary_host_catalog_plugin" "aws_plugin" {
  name        = "aws-dynamic-host-catalog"
  description = "AWS EC2 dynamic discovery via Boundary plugin"
  #scope_id   = boundary_scope.project.id
  scope_id   = local.project_scope_id
  plugin_name = "aws"

  # REQUIRED for AssumeRole in HCP: route catalog ops to the AWS worker
  worker_filter = "\"self-managed-aws-worker\" in \"/tags/type\""
  
  ##########################################
  # Plugin configuration
  ##########################################
  attributes_json = jsonencode({
    region = var.aws_region

    #role_arn = aws_iam_role.boundary_discovery_role.arn
    role_arn = local.boundary_discovery_role_arn

    # Prevent Boundary from trying to rotate creds
    disable_credential_rotation = true
  })

  ##########################################
  # AWS credentials used by Boundary runtime
  ##########################################
 # secrets_json = jsonencode({
 #   access_key_id     = aws_iam_access_key.boundary_dynamic_host_catalog.id
 #   secret_access_key = aws_iam_access_key.boundary_dynamic_host_catalog.secret
 # })

  ##########################################
  # 🔑 CRITICAL FIX (Option A)
  #
  # Ensures Boundary plugin is replaced
  # whenever the AWS access key changes
  ##########################################
  #lifecycle {
  #  replace_triggered_by = [
  #    aws_iam_access_key.boundary_dynamic_host_catalog
  #  ]
  #}

  ##########################################
  # Ensure IAM user + key exist first
  ##########################################
#  depends_on = [time_sleep.boundary_dynamic_host_catalog_user_ready]
#  depends_on = [
   # time_sleep.wait_for_worker_registration,
   # aws_instance.boundary_self_managed_worker,
   # aws_iam_role_policy.boundary_worker_ec2_read,
   # aws_iam_role_policy.boundary_discovery_policy,
   # aws_iam_role_policy.worker_assume_discovery_policy
 #aws_instance.boundary_self_managed_worker,
 #   aws_iam_role_policy.boundary_worker_ec2_read,
 #   aws_iam_role_policy.boundary_discovery_policy,
 #   aws_iam_role_policy.worker_assume_discovery_policy
 # ]
}

#commnet out 2/3/2026
#resource "time_sleep" "boundary_dynamic_host_catalog_user_ready" {
#  depends_on = [
#    aws_iam_user.boundary_dynamic_host_catalog,
#    aws_iam_access_key.boundary_dynamic_host_catalog,
#    aws_iam_user_policy.boundary_dynamic_host_catalog
#  ]

#  create_duration = "30s"
#}







/*
resource "boundary_host_catalog_plugin" "aws_plugin" {
  name            = "ws-dynamic-host-catalog"
  description     = "Host catalog in AWS Sandbox"
  #scope_id        = boundary_scope.project.id
  scope_id        = local.project_scope_id
  plugin_name     = "aws"
  attributes_json = jsonencode({
  #removed 1-26-2026
  #"region" = data.aws_region.current.name,
  #added this line 1-26-2026
  region = var.aws_region,
  "disable_credential_rotation" = true 
  })
  
  secrets_json = jsonencode({
    "access_key_id"     = aws_iam_access_key.boundary_dynamic_host_catalog.id
    "secret_access_key" = aws_iam_access_key.boundary_dynamic_host_catalog.secret
  })
  depends_on = [time_sleep.boundary_dynamic_host_catalog_user_ready]
}
#PB end 7/25/2024

#PB comment out below
# Boundary config for the EC2 target
#resource "boundary_host_catalog_plugin" "aws_plugin" {
#  name        = "AWS Catalogue"
#  description = "AWS Host Catalogue"
#  scope_id    = boundary_scope.project.id
#  plugin_name = "aws"
 # attributes_json = jsonencode({
 #   "region" = "us-east-1",
 #   "disable_credential_rotation" = true })
#
 # secrets_json = jsonencode({
 #   "access_key_id"     = var.aws_access,
 #   "secret_access_key" = var.aws_secret
 # })
#}
#PB end comment out 7/25/2024
*/









resource "boundary_host_set_plugin" "aws_db" {
  name                  = "AWS DB Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:service-type=database" })
  sync_interval_seconds = 30
  depends_on = [
    boundary_worker.self_managed_pki_worker,
    boundary_host_catalog_plugin.aws_plugin,
    boundary_worker.self_managed_pki_worker
  ]
}

resource "boundary_host_set_plugin" "aws_dev" {
  name                  = "AWS Dev Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:application=dev" })
  sync_interval_seconds = 30
  depends_on = [
    boundary_worker.self_managed_pki_worker,
    boundary_host_catalog_plugin.aws_plugin,
    boundary_worker.self_managed_pki_worker
  ]
}

resource "boundary_host_set_plugin" "aws_prod" {
  name                  = "AWS Prod Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:application=production" })
  sync_interval_seconds = 30
  depends_on = [
    boundary_worker.self_managed_pki_worker,
    boundary_host_catalog_plugin.aws_plugin,
    boundary_worker.self_managed_pki_worker
  ]
}

resource "boundary_target" "aws" {
  type                     = "ssh"
  name                     = "aws-ec2"
  description              = "AWS EC2 Target"
  egress_worker_filter     = " \"self-managed-aws-worker\" in \"/tags/type\" "
  #scope_id                 = boundary_scope.project.id
  scope_id                 = local.project_scope_id
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [
    boundary_host_set_plugin.aws_db.id,
    boundary_host_set_plugin.aws_dev.id,
    boundary_host_set_plugin.aws_prod.id,
  ]
  #PB vommnet out temp. 
  #enable_session_recording                   = true
  #storage_bucket_id                          = boundary_storage_bucket.boundary_storage_bucket.id
  injected_application_credential_source_ids = [boundary_credential_library_vault_ssh_certificate.vault_ssh_cert.id]
}

resource "boundary_policy_storage" "strict_storage_policy" {
  #scope_id          = boundary_scope.org.id
  scope_id          = local.org_scope_id
  delete_after_days = 1
  retain_for_days   = 0
  name              = "strictdeletepolicy"
  description       = "Policy to allow deletion at any time"
}

resource "boundary_scope_policy_attachment" "policy_attachment" {
  policy_id = boundary_policy_storage.strict_storage_policy.id
  #scope_id  = boundary_scope.org.id
  scope_id  = local.org_scope_id
}
