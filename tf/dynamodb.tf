# DynamoDB table for last-login timestamps
resource "aws_dynamodb_table" "last_login" {
  name         = "awsauth-last-login"
  billing_mode = "PAY_PER_REQUEST" # on-demand
  hash_key     = "user_sub"        # partition key

  attribute {
    name = "user_sub"
    type = "S"
  }

  # Optional but nice: point-in-time recovery (PITR)
  point_in_time_recovery {
    enabled = false
  }

  server_side_encryption {
    enabled = true # AES-256 (AWS owned key)
  }

  tags = {
    Name    = "awsauth-last-login"
    Project = "awsauth"
  }
}

# Handy outputs
output "ddb_table_name" {
  value = aws_dynamodb_table.last_login.name
}

output "ddb_table_arn" {
  value = aws_dynamodb_table.last_login.arn
}
