###############################################################
# Cognito (FOUNDATION + CONSOLE-OAUTH PATTERN)
#
# What Terraform manages now:
#  - User Pool: EMAIL-ONLY sign-in, email auto-verify, strong password policy
#  - Public App Client: NO OAuth config in TF (drift-safe via ignore_changes)
#  - AWS-managed Hosted UI domain (safe prefix; avoids "aws" reserved word)
#
# What you will set in the Console AFTER apply (one-time):
#  - Identity provider: Cognito user pool
#  - OAuth flow: Authorization code grant (PKCE ON)
#  - Scopes: openid, email, profile
#  - Callback URL(s): https://<cloudfront_domain>/auth/callback/    (TRAILING SLASH)
#  - Sign-out URL(s): https://<cloudfront_domain>/
#  - Default redirect: https://<cloudfront_domain>/auth/callback/
#
# Notes:
#  - We IGNORE OAuth fields so your console edits won't drift.
#  - To bring OAuth back under IaC later: remove ignore_changes, add fields, apply.
###############################################################

resource "aws_cognito_user_pool" "this" {
  name = "${local.name_prefix}-pool"

  # EMAIL-ONLY sign-in (no username)
  username_attributes = ["email"]         # users sign in with email only
  username_configuration {
    case_sensitive = false
  }

  auto_verified_attributes = ["email"]    # send verification to email

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = "OFF"

  # Stronger error posture / protections
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

# Public client (no secret), NO OAuth config in Terraform
resource "aws_cognito_user_pool_client" "app" {
  name         = "${local.name_prefix}-app"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  enable_token_revocation = true
  refresh_token_validity  = 30
  access_token_validity   = 60
  id_token_validity       = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # IMPORTANT: allow console-only OAuth config without Terraform drift
  lifecycle {
    ignore_changes = [
      allowed_oauth_flows_user_pool_client,
      allowed_oauth_flows,
      supported_identity_providers,
      allowed_oauth_scopes,
      callback_urls,
      logout_urls,
      default_redirect_uri,
    ]
  }
}

# AWS-managed Hosted UI domain (avoid reserved words like "aws")
resource "random_id" "cognito" {
  byte_length = 3
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "auth-${random_id.cognito.hex}"  # e.g., auth-59d040
  user_pool_id = aws_cognito_user_pool.this.id
}
