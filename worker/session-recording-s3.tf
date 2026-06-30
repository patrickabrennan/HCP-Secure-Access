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
