# Origin Access Control (OAC) for SigV4 to S3
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.name_prefix}-oac"
  description                       = "OAC for ${local.name_prefix} static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Security response headers (CSP/HSTS/etc.)
resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${local.name_prefix}-security-headers"

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self'; connect-src 'self' https://*.amazoncognito.com; object-src 'none'; base-uri 'self'; frame-ancestors 'none';"
      override                = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = false
      preload                    = false
      override                   = true
    }

    content_type_options {
      override = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "no-referrer"
      override        = true
    }
  }
}

resource "aws_cloudfront_distribution" "site" {
  comment             = "${local.name_prefix} static site"
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  web_acl_id          = aws_wafv2_web_acl.site.arn


  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = "s3-origin-${aws_s3_bucket.site.id}"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin-${aws_s3_bucket.site.id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # Use AWS managed caching policy (CachingOptimized)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    # Attach our security headers
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
  }

  # Friendly error mapping to our static 404 page
  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_cloudfront_response_headers_policy.security
  ]
}
