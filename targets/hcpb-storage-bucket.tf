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

#New addition as of 6/30/2026
resource "aws_s3_bucket" "boundary_session_recording_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = var.s3_bucket_name_tags
    Environment = var.s3_bucket_env_tags
  }
}

resource "aws_s3_bucket_public_access_block" "boundary_session_recording_bucket" {
  bucket = aws_s3_bucket.boundary_session_recording_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "boundary_session_recording_bucket" {
  bucket = aws_s3_bucket.boundary_session_recording_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "boundary_session_recording_bucket" {
  bucket = aws_s3_bucket.boundary_session_recording_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "boundary_storage_bucket" "boundary_storage_bucket" {
  name        = "${random_pet.unique_names.id}-session-recording-bucket"
  description = "S3 bucket for Boundary SSH and RDP session recording"

  scope_id    = "global"
  plugin_name = "aws"
  bucket_name = aws_s3_bucket.boundary_session_recording_bucket.bucket

  attributes_json = jsonencode({
    region                      = var.aws_region
    disable_credential_rotation = true
  })

  worker_filter = "\"self-managed-aws-worker\" in \"/tags/type\""

  depends_on = [
    aws_s3_bucket.boundary_session_recording_bucket,
    aws_s3_bucket_public_access_block.boundary_session_recording_bucket,
    aws_s3_bucket_server_side_encryption_configuration.boundary_session_recording_bucket,
    aws_s3_bucket_versioning.boundary_session_recording_bucket
  ]
}

output "boundary_storage_bucket_id" {
  value = boundary_storage_bucket.boundary_storage_bucket.id
}
