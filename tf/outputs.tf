output "cloudfront_domain" {
  description = "CloudFront distribution domain (your site URL base)."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "base_site_url" {
  description = "Convenience: https://<cloudfront_domain>"
  value       = local.base_site_url
}

output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.app.id
}

output "hosted_ui_domain" {
  description = "Cognito Hosted UI base URL (AWS-managed domain)."
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.region}.amazoncognito.com"
}
