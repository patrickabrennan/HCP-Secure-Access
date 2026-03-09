resource "boundary_worker" "self_managed_pki_worker" {
  scope_id                    = "global"
  name                        = "boundary-aws-worker"
  worker_generated_auth_token = ""
}

locals {
  boundary_worker_service_config = <<-SERVICE
[Unit]
Description=HashiCorp Boundary - Identity-based access management for dynamic infrastructure
Documentation=https://developer.hashicorp.com/boundary
After=network-online.target time-sync.target
Wants=network-online.target time-sync.target
ConditionPathExists=/usr/local/bin/render-boundary-worker-config
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
EnvironmentFile=-/etc/boundary.d/boundary.env
User=boundary
Group=boundary
TimeoutStartSec=120
ExecStartPre=+/usr/local/bin/render-boundary-worker-config
ExecStart=/usr/bin/boundary server -config=/etc/boundary.d/pki-worker.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
SERVICE

  render_boundary_worker_config_script = <<-SCRIPT
#!/bin/bash
set -euo pipefail

mkdir -p /etc/boundary.d
mkdir -p /etc/boundary.d/worker
mkdir -p /etc/boundary.d/sessionrecord

TOKEN="$(curl -sf -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)"

IP=""
for i in $(seq 1 30); do
  IP="$(curl -sf -H "X-aws-ec2-metadata-token: ${TOKEN}" \
    http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || true)"
  [ -n "$IP" ] && break
  sleep 2
done

if [ -z "$IP" ]; then
  IP="$(curl -sf -H "X-aws-ec2-metadata-token: ${TOKEN}" \
    http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || true)"
fi

if [ -z "$IP" ]; then
  echo "Unable to determine instance IP from EC2 metadata" >&2
  exit 1
fi

cat > /etc/boundary.d/pki-worker.hcl <<EOF
disable_mlock = true

hcp_boundary_cluster_id = "${split(".", split("//", var.boundary_addr)[1])[0]}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "${IP}:9202"
  auth_storage_path = "/etc/boundary.d/worker"
  recording_storage_path = "/etc/boundary.d/sessionrecord"
  controller_generated_activation_token = "${boundary_worker.self_managed_pki_worker.controller_generated_activation_token}"

  tags {
    type = ["self-managed-aws-worker"]
  }
}
EOF

chown -R boundary:boundary /etc/boundary.d
chmod 700 /etc/boundary.d/worker
chmod 700 /etc/boundary.d/sessionrecord
chmod 640 /etc/boundary.d/pki-worker.hcl
SCRIPT

  cloudinit_boundary_worker = {
    write_files = [
      {
        path        = "/etc/systemd/system/boundary.service"
        content     = local.boundary_worker_service_config
        permissions = "0644"
      },
      {
        path        = "/usr/local/bin/render-boundary-worker-config"
        content     = local.render_boundary_worker_config_script
        permissions = "0755"
      }
    ]
  }
}

data "cloudinit_config" "boundary_self_managed_worker" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
#!/bin/bash
set -euo pipefail

if command -v dnf >/dev/null 2>&1; then
  dnf install -y shadow-utils yum-utils curl || true
  rpm -q boundary-enterprise >/dev/null 2>&1 || {
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    dnf install -y boundary-enterprise
  }
else
  yum install -y shadow-utils yum-utils curl || true
  rpm -q boundary-enterprise >/dev/null 2>&1 || {
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum install -y boundary-enterprise
  }
fi

id boundary >/dev/null 2>&1 || useradd --system --home /etc/boundary.d --shell /sbin/nologin boundary

mkdir -p /etc/boundary.d
mkdir -p /etc/boundary.d/worker
mkdir -p /etc/boundary.d/sessionrecord

chown -R boundary:boundary /etc/boundary.d
chmod 700 /etc/boundary.d/worker
chmod 700 /etc/boundary.d/sessionrecord
EOF
  }

  part {
    content_type = "text/cloud-config"
    content      = yamlencode(local.cloudinit_boundary_worker)
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
#!/bin/bash
set -euo pipefail

systemctl daemon-reload
systemctl enable boundary
systemctl restart boundary
EOF
  }
}

resource "aws_instance" "boundary_self_managed_worker" {
  ami                         = var.aws_ami
  key_name                    = var.admin_key_name != "" ? var.admin_key_name : null
  instance_type               = var.aws_instance_type
  availability_zone           = var.availability_zone
  user_data_replace_on_change = true
  user_data_base64            = data.cloudinit_config.boundary_self_managed_worker.rendered
  subnet_id                   = aws_subnet.boundary_db_demo_subnet.id
  vpc_security_group_ids      = [aws_security_group.boundary_ingress_worker_ssh.id]
  iam_instance_profile        = aws_iam_instance_profile.boundary_worker_instance_profile.name

  tags = {
    Name = "Boundary Self-Managed Worker"
  }

  depends_on = [
    boundary_worker.self_managed_pki_worker
  ]
}













/*

# Define a Boundary worker. The worker_generated_auth_token should
#always be left as "" if you are deploying a Controller-led authorisation flow.
#This will result in the controller generating the one-time token to use, that must be
#passed into the worker configuration file.
#
resource "boundary_worker" "self_managed_pki_worker" {
  scope_id                    = "global" 
  name                        = "bounday-aws-worker"
  worker_generated_auth_token = ""

 # lifecycle {
 #   prevent_destroy = true
 # }
}
 
/* This locals block sets out the configuration for the Boundary Service file and
the HCL configuration for the PKI Worker. Within the boundary_egress_worker_hcl_config
the controller_generated_activation_token pulls in the one-time token generated by the
boundary_worker resource above.

The cloud_init config takes the content of the two configurations and specifies the path
on the EC2 instance to write to.
*/
locals {
  boundary_self-managed_worker_service_config = <<-WORKER_SERVICE_CONFIG
  [Unit]
  Description="HashiCorp Boundary - Identity-based access management for dynamic infrastructure"
  Documentation=https://www.boundaryproject.io/docs

  # Delay startup until the primary ENI has a routable IP.  "network.target"
  # only means the network subsystem has initialised; "network-online.target"
  # means at least one interface is fully configured.  Without this, boundary
  # can start (and fail) before the instance has connectivity to HCP on reboots.
  # Wants= (not Requires=) so the unit isn't permanently blocked if the target
  # is masked or takes unusually long.
  After=network-online.target
  Wants=network-online.target

  # Wait for chrony (pointed at the AWS Time Sync Service, 169.254.169.123 on
  # AL2023) to complete its first synchronisation.  The PKI activation token
  # and all subsequent TLS handshakes with HCP are time-sensitive; a skewed
  # clock produces validation errors that are difficult to diagnose.
  # time-sync.target is activated by systemd-time-wait-sync.service once chrony
  # reports a good initial sample.
  After=time-sync.target
  Wants=time-sync.target

  # Refuse to start if the HCL config has not been written yet (e.g. a partial
  # cloud-init run on first boot).  Fails with a clear condition message rather
  # than a cryptic "file not found" from the boundary binary.
  ConditionPathExists=/etc/boundary.d/pki-worker.hcl

  # Cap restart attempts so a persistent failure (bad token, missing config,
  # etc.) doesn't spin indefinitely.  With Restart=on-failure below, systemd
  # will give up after 3 starts within 60 s and require manual intervention.
  StartLimitIntervalSec=60
  StartLimitBurst=3

  [Service]
  EnvironmentFile=-/etc/boundary.d/boundary.env
  User=boundary
  Group=boundary
  #ProtectSystem=full
  #ProtectHome=read-only

  # ExecStartPre retries the IMDS public-ipv4 query for up to ~60 s (30 × 2 s),
  # then boundary itself needs time to reach HCP and complete registration.
  # The default TimeoutStartSec=90 s is too tight; 120 s gives comfortable
  # headroom without masking genuine hangs.
  TimeoutStartSec=120

  # Run as root (+) so the script can write to /etc/boundary.d/public_addr and
  # set ownership before dropping to the boundary user for ExecStart.
  ExecStartPre=+/usr/local/bin/boundary-fetch-addr
  ExecStart=/usr/bin/boundary server -config=/etc/boundary.d/pki-worker.hcl
  ExecReload=/bin/kill --signal HUP $MAINPID
  KillMode=process
  KillSignal=SIGINT
  Restart=on-failure
  RestartSec=5
  TimeoutStopSec=30
  LimitMEMLOCK=infinity

  [Install]
  WantedBy=multi-user.target
  WORKER_SERVICE_CONFIG

  boundary_self-managed_worker_hcl_config = <<-WORKER_HCL_CONFIG
  disable_mlock = true

  hcp_boundary_cluster_id = "${split(".", split("//", var.boundary_addr)[1])[0]}"

  listener "tcp" {
    address = "0.0.0.0:9202"
    purpose = "proxy"
  }

  worker {
    public_addr = "file:///etc/boundary.d/public_addr"
    auth_storage_path = "/etc/boundary.d/worker"
    recording_storage_path = "/etc/boundary.d/sessionrecord"
    controller_generated_activation_token = "${boundary_worker.self_managed_pki_worker.controller_generated_activation_token}"
    tags {
      type = ["self-managed-aws-worker"]
    }
  }
WORKER_HCL_CONFIG

  boundary_fetch_addr_script = <<-FETCH_ADDR_SCRIPT
  #!/bin/bash
  # Resolves the EC2 instance's public IPv4 address and writes it (with the
  # Boundary proxy port) to /etc/boundary.d/public_addr, which pki-worker.hcl
  # reads via: public_addr = "file:///etc/boundary.d/public_addr"
  #
  # This script runs as root via ExecStartPre=+ each time the boundary service
  # starts, so the address is always current (handles EIP reassignment, etc.).
  # Doing this at service-start time — rather than cloud-init time — avoids the
  # race where the public IP is not yet visible through IMDS on first boot.
  set -euo pipefail

  # Obtain an IMDSv2 session token. The TTL only needs to outlive this script;
  # 21600 s (6 h) is the maximum allowed and is the conventional value to use.
  # "|| true" prevents set -e from aborting if IMDS is momentarily unreachable.
  TOKEN=$(curl -sf -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true)

  # Poll the public-ipv4 metadata key until it is populated.  On a freshly
  # launched instance with map_public_ip_on_launch=true, AWS may take several
  # seconds to associate the public IP, so the IMDS key returns empty until
  # that association is complete.  Retry for up to ~60 s (30 × 2 s) before
  # giving up and falling back to the private IP.
  IP=""
  for i in $(seq 1 30); do
    IP=$(curl -sf -H "X-aws-ec2-metadata-token: $TOKEN" \
      "http://169.254.169.254/latest/meta-data/public-ipv4" 2>/dev/null || true)
    [ -n "$IP" ] && break
    sleep 2
  done

  # If no public IP was found (private-only subnet, or EIP not yet attached),
  # fall back to the primary private IPv4.  Boundary will still function for
  # targets reachable via private routing; the worker just won't be reachable
  # from the public internet on this address.
  if [ -z "$IP" ]; then
    IP=$(curl -sf -H "X-aws-ec2-metadata-token: $TOKEN" \
      "http://169.254.169.254/latest/meta-data/local-ipv4" || true)
  fi

  # If we still have nothing, abort — starting boundary with an empty
  # public_addr file would produce a confusing runtime error.
  if [ -z "$IP" ]; then
    echo "boundary-fetch-addr: could not determine any IP address" >&2
    exit 1
  fi

  # Write the address in host:port form.  Port 9202 must match the listener
  # block in pki-worker.hcl.  The boundary process reads this file at startup.
  echo "$IP:9202" > /etc/boundary.d/public_addr
  # Ensure the boundary user can read the file (the service runs as boundary:boundary).
  chown boundary:boundary /etc/boundary.d/public_addr
  chmod 0644 /etc/boundary.d/public_addr
  FETCH_ADDR_SCRIPT

  cloudinit_config_boundary_self-managed_worker = {
    write_files = [
      {
        content = local.boundary_self-managed_worker_service_config
        path    = "/usr/lib/systemd/system/boundary.service"
      },
      {
        content = local.boundary_self-managed_worker_hcl_config
        path    = "/etc/boundary.d/pki-worker.hcl"
      },
      {
        content     = local.boundary_fetch_addr_script
        path        = "/usr/local/bin/boundary-fetch-addr"
        permissions = "0755"
      },
    ]
  }
}

/* This data block pulls in all the different parts of the configuration to be deployed.
These are executed in the order that they are written. Firstly, the boundary-worker binary
will be called. Secondly, the configuration specified in the locals block will be called.
Lastly the boundary-worker process is started using the pki-worker.hcl file.
*/
data "cloudinit_config" "boundary_self-managed_worker" {
  gzip          = false
  base64_encode = true

  # Install Boundary, write IP (public if available), and prep directories/permissions for the boundary user
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      set -euo pipefail

      sudo yum install --skip-broken --best --allowerasing -y shadow-utils yum-utils curl
      #sudo yum install -y shadow-utils yum-utils curl
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      sudo yum -y install boundary-enterprise

      # REQUIRED: worker writes to these paths; service runs as boundary:boundary
      # public_addr is populated at service start by ExecStartPre=/usr/local/bin/boundary-fetch-addr
      sudo mkdir -p /etc/boundary.d/sessionrecord /etc/boundary.d/worker
      sudo chown -R boundary:boundary /etc/boundary.d
      sudo chmod 700 /etc/boundary.d/worker
    EOF
  }

  # Write systemd unit + worker HCL
  part {
    content_type = "text/cloud-config"
    content      = yamlencode(local.cloudinit_config_boundary_self-managed_worker)
  }

  # Start the worker via systemd (do NOT run `boundary server` here)
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      set -euo pipefail

      sudo systemctl daemon-reload
      sudo systemctl enable boundary
      sudo systemctl restart boundary || sudo systemctl start boundary
    EOF
  }
}

#Create the Boundary worker instance and specify the data block in the user_data_base64
#parameter. The depends_on argument is set to ensure that the networking is establish first
#and that the boundary_worker resource also completes, to ensure the token is generated first.

#resource "aws_instance" "boundary_self_managed_worker" {
#  ami                         = var.aws_ami
#  key_name                    = "sap"
#  instance_type               = "t2.micro"
#  availability_zone           = var.availability_zone
#  user_data_replace_on_change = true
#  user_data_base64            = data.cloudinit_config.boundary_self-managed_worker.rendered
#  subnet_id                   = aws_subnet.boundary_db_demo_subnet.id
#  vpc_security_group_ids      = [aws_security_group.boundary_ingress_worker_ssh.id]

  # Attach instance profile so the worker can use IMDS credentials (AssumeRole, etc.)
 # iam_instance_profile        = aws_iam_instance_profile.boundary_worker_instance_profile.name

  #tags = {
   # Name = "Boundary Self-Managed Worker"
  #}

 # lifecycle {
 #   prevent_destroy = true
 # }
#}
#*/
