############################
# Instance types (free-tier friendly)
############################
variable "instance_type_bastion" {
  type    = string
  default = "t2.micro" # free tier (switch to t3.micro if t2 not available)
}

variable "instance_type_private" {
  type    = string
  default = "t2.micro" # free tier
}

############################
# AMI lookup (Amazon Linux 2)
############################
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

############################
# Bastion EC2 (public subnet) with agent forwarding
############################
locals {
  bastion_user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    SSHD_CFG="/etc/ssh/sshd_config"
    sed -i 's/^#\\?PasswordAuthentication .*/PasswordAuthentication no/' "$SSHD_CFG"
    sed -i 's/^#\\?PermitRootLogin .*/PermitRootLogin prohibit-password/' "$SSHD_CFG"
    sed -i 's/^#\\?AllowAgentForwarding .*/AllowAgentForwarding yes/' "$SSHD_CFG"
    sed -i 's/^#\\?AllowTcpForwarding .*/AllowTcpForwarding yes/' "$SSHD_CFG"
    systemctl restart sshd
  EOF
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type_bastion
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id] # from secgroups.tf
  key_name                    = "bastpriv"
  associate_public_ip_address = true
  user_data                   = local.bastion_user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "awsauth-bastion"
    Project = "awsauth"
  }
}

############################
# Private EC2 (private subnet)
############################
resource "aws_instance" "private_ec2" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type_private
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id] # from secgroups.tf
  key_name                    = "bastpriv"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.private_ec2_profile.name


  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "awsauth-private-ec2"
    Project = "awsauth"
  }
}
