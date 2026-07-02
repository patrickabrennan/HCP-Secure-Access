output "boundary_storage_bucket_id" {
  value = boundary_storage_bucket.boundary_storage_bucket.id
}

output "rdp_target_id" {
  value = boundary_target.rdp.id
}
