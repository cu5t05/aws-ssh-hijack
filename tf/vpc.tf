# VPC
resource "aws_vpc" "awsauth" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "awsauth"
    Project = "awsauth"
  }
}

# Internet Gateway (for public subnet)
resource "aws_internet_gateway" "awsauth" {
  vpc_id = aws_vpc.awsauth.id

  tags = {
    Name    = "awsauth-igw"
    Project = "awsauth"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.awsauth.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "awsauth-public-1a"
    Project = "awsauth"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.awsauth.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name    = "awsauth-private-1a"
    Project = "awsauth"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.awsauth.id

  tags = {
    Name    = "awsauth-rt-public"
    Project = "awsauth"
  }
}

# Public Route: IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.awsauth.id
}

# Public RT Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table (no internet route)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.awsauth.id

  tags = {
    Name    = "awsauth-rt-private"
    Project = "awsauth"
  }
}

# Private RT Association
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
