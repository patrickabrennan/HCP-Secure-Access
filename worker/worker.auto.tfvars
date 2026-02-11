aws_region = "us-east-1"
availability_zone = "us-east-1a"
availability_zone2 = "us-east-1b"

aws_ami = "ami-070b7c2988d4e2c89"
 
boundary_addr = "https://0d74e37c-2b8c-47e2-b0b0-52501188d184.boundary.hashicorp.cloud"
auth_method_id = "ampw_EQALDorSbL"

aws_vpc_cidr = "172.40.0.0/16"
aws_subnet_cidr = "172.40.10.0/24"
aws_subnet_cidr2 = "172.40.20.0/24"

vault_addr = "https://Pat-Brennan-SE-East-vault-cluster-public-vault-01691920.0ac6f10f.z1.hashicorp.cloud:8200"
 
db_username = "dbadmin"
db_password = "dbpassword"
db_name = "dbname"

s3_bucket_name = "pb-s3-hcpb-bucket"
s3_bucket_name_tags = "session-recording"
s3_bucket_env_tags = "boundary"

#addexd 9-25-2025
# For AD dynamic creds
#rdp_vault_creds_path = "kv-rdp/boundary/rdp/svc"  #"ad/creds/boundary-rdp"

# OR, for Windows local-account rotation
# rdp_vault_creds_path = "windows/creds/boundary-rdp"
#end add 9-25-2025

vault_kv_mount_path   = "kv-rdp"
vault_kv_secret_path  = "boundary/rdp/svc"
rdp_vault_creds_path  = "kv-rdp/boundary/rdp/svc"
create_kv_mount       = true

