# User Pool - handles admin login
resource "aws_cognito_user_pool" "main" {
  name = "fourallthedogs-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  tags = {
    Project = "fourallthedogs"
  }
}

# User Pool Client - what admin.html uses to authenticate
resource "aws_cognito_user_pool_client" "main" {
  name         = "fourallthedogs-client"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}

# Identity Pool - gives guest customers temporary IAM credentials
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "fourallthedogs_identity_pool"
  allow_unauthenticated_identities = true

  tags = {
    Project = "fourallthedogs"
  }
}

# Attach IAM roles to Identity Pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    unauthenticated = aws_iam_role.cognito_unauthenticated.arn
  }
}