locals {
  name_prefix = var.project_slug

  # Derived URLs (become non-null after distribution is created)
  base_site_url = try("https://${aws_cloudfront_distribution.site.domain_name}", null)
  callback_url  = try("${local.base_site_url}/auth/callback/", null) # keep trailing slash
  logout_url    = try("${local.base_site_url}/", null)
}
