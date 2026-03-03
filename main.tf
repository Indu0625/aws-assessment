terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

# -----------------------------
# Cognito User Pool (us-east-1)
# -----------------------------
resource "aws_cognito_user_pool" "main" {
  provider = aws.use1

  name = "assessment-user-pool"

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "app_client" {
  provider = aws.use1

  name         = "assessment-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user" "test_user" {
  provider     = aws.use1
  user_pool_id = aws_cognito_user_pool.main.id
  username     = "avulaindu096@gmail.com"

  attributes = {
    email          = "avulaindu096@gmail.com"
    email_verified = "true"
  }

  temporary_password = "TempPassword123!"
  message_action     = "SUPPRESS"
}