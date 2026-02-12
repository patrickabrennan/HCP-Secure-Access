resource "aws_instance" "boundary_public_target" {
  ami               = var.aws_ami
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  #user_data_base64  = data.cloudinit_config.ssh_trusted_ca.rendered
  user_data = <<-EOF
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
sudo bash -c 'curl -o /etc/ssh/trusted-user-ca-keys.pem \
--header "X-Vault-Namespace: admin" \
-X GET \
${var.vault_addr}/v1/ssh-client-signer/public_key'
sudo bash -c 'echo TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem >> /etc/ssh/sshd_config'
sudo bash -c 'systemctl restart sshd.service'
EOF

  #9/28/2025 change from network_interface to primary_network_interface per TF warning message
  #primary_network_interface {
  #  network_interface_id = aws_network_interface.boundary_public_target_ni.id
  #  #device_index         = 0
  #}
  network_interface {
    network_interface_id = aws_network_interface.boundary_public_target_ni.id
    device_index         = 0
  }
  tags = {
    Name         = "boundary-1-dev",
    service-type = "database",
    application  = "dev",
  }
}

resource "aws_network_interface" "boundary_public_target_ni" {
  #subnet_id               = aws_subnet.boundary_db_demo_subnet.id
  #security_groups         = [aws_security_group.allow_all.id]
  subnet_id       = local.boundary_db_demo_subnet_id
  #security_groups = [local.allow_all_sg_id]
  security_groups = [local.boundary_target_sg_id]
  private_ip_list_enabled = false
}

//Configure the EC2 host to trust Vault as the CA
#data "cloudinit_config" "ssh_trusted_ca" {
#  gzip          = false
#  base64_encode = true

#  part {
#    content_type = "text/x-shellscript"
#    content      = <<-EOF
#    #!/bin/bash
#    sudo bash -c 'curl -o /etc/ssh/trusted-user-ca-keys.pem \
#    --header "X-Vault-Namespace: admin" \
#    -X GET \
#    ${var.vault_addr}/v1/ssh-client-signer/public_key'
#    sudo bash -c 'echo TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem >> /etc/ssh/sshd_config'
#    sudo bash -c 'systemctl restart sshd.service'
#    EOF
#  }

#  part {
#    content_type = "text/x-shellscript"
#    content      = <<-EOF
#    #!/bin/bash
#    sudo bash -c 'adduser admin_user'
#    sudo nash -c 'adduser danny'
#    EOF
#  }
#}
