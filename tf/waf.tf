# CloudFront-scoped WAF must be created in us-east-1
resource "aws_wafv2_web_acl" "site" {
  provider = aws.us_east_1

  name  = "${local.name_prefix}-acl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "common"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "badinputs"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 30
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "iprep"
      sampled_requests_enabled   = false
    }
  }

  # Gentle rate limit to cut abuse without affecting normal users
  rule {
    name     = "RateLimit"
    priority = 40

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "ratelimit"
      sampled_requests_enabled   = false
    }
  }
}


