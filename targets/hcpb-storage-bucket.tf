#resource "boundary_storage_bucket" "boundary_storage_bucket" {
#  name            = "${random_pet.unique_names.id}-session-recording-bucket"
#  scope_id        = "global"
#  plugin_name     = "aws"
#  bucket_name     = aws_s3_bucket.boundary_session_recording_bucket.bucket
#  attributes_json = jsonencode({ "region" = var.aws_region, "disable_credential_rotation" = true })

# secrets_json = jsonencode({
#    "access_key_id"     = var.aws_access,
#    "secret_access_key" = var.aws_secret
#  })
#  worker_filter = " \"self-managed-aws-worker\" in \"/tags/type\" "

 # depends_on = [aws_s3_bucket.boundary_session_recording_bucket, aws_db_instance.boundary_demo]

#}
#added 6/30/2026
resource "boundary_storage_bucket" "boundary_storage_bucket" {
  name        = "${random_pet.unique_names.id}-session-recording-bucket"
  description = "S3 bucket for Boundary SSH and RDP session recording"

  scope_id    = "global"
  plugin_name = "aws"

#Commented out 6/30/2026
  #bucket_name = data.terraform_remote_state.worker.outputs.boundary_session_recording_bucket_name

  attributes_json = jsonencode({
    region                      = var.aws_region
    disable_credential_rotation = true
  })

  worker_filter = "\"self-managed-aws-worker\" in \"/tags/type\""
}
