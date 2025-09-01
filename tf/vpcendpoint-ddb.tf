# If your provider is set to us-east-1, set this to the same region
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

resource "aws_vpc_endpoint" "ddb" {
  vpc_id            = aws_vpc.awsauth.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"

  # Attach to the PRIVATE route table so private subnets use this path
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name    = "awsauth-ddb-endpoint"
    Project = "awsauth"
  }
}

output "ddb_vpc_endpoint_id" {
  value = aws_vpc_endpoint.ddb.id
}
