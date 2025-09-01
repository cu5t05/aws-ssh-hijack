variable "region" {
  description = "Primary AWS region (Cognito is regional; WAF-CF is global in us-east-1)."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

# WAF for CloudFront must be created in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

