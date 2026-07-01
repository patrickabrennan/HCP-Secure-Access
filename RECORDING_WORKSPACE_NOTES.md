# Boundary Session Recording Workspace Layout

This repo is split into three workspaces:

1. `worker`
   - Creates the real AWS S3 bucket for Boundary session recordings.
   - Gives the Boundary worker IAM role S3 access.
   - Outputs the S3 bucket name and ARN.

2. `recordings`
   - Creates the Boundary `boundary_storage_bucket` object.
   - Reads the AWS S3 bucket name from the `worker` workspace remote state.
   - Outputs `boundary_storage_bucket_id` for targets.
   - Uses `lifecycle { prevent_destroy = true }` so normal cleanup does not fail while recordings still exist.

3. `targets`
   - Creates SSH/RDP/DB targets.
   - Reads `boundary_storage_bucket_id` from the `recordings` workspace remote state.
   - Does not create or delete the Boundary storage bucket.

Apply order:

```text
worker -> recordings -> targets
```

Normal target rebuild/destroy:

```text
destroy/redeploy targets only
```

Full cleanup:

```text
1. destroy targets
2. delete Boundary session recordings / wait for retention cleanup
3. remove or temporarily comment prevent_destroy in recordings/hcpb-storage-bucket.tf
4. destroy recordings
5. destroy worker
```
