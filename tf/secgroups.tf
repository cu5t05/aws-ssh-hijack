########################################
# Security Groups for bastion & private
########################################

# Bastion SG: SSH from anywhere; egress all
resource "aws_security_group" "bastion_sg" {
  name        = "awsauth-bastion-sg"
  description = "SSH from anywhere; egress all"
  vpc_id      = aws_vpc.awsauth.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "awsauth-bastion-sg"
    Project = "awsauth"
  }
}

# Private EC2 SG: SSH only from bastion SG; egress all
resource "aws_security_group" "private_sg" {
  name        = "awsauth-private-sg"
  description = "Allow SSH from bastion SG; egress all"
  vpc_id      = aws_vpc.awsauth.id

  ingress {
    description     = "SSH from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "awsauth-private-sg"
    Project = "awsauth"
  }
}

# Outputs for wiring into EC2 resources
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}
