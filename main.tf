# =====================================
# US EAST STACK
# =====================================

module "us_east_stack" {
  source = "./modules/regional_stack"

  region_name          = "us-east-1"
  table_name           = "greeting-logs-us"
  cognito_user_pool_id = var.cognito_user_pool_id
  cognito_client_id    = var.cognito_client_id
}

# =====================================
# EU WEST STACK
# =====================================

module "eu_west_stack" {
  source = "./modules/regional_stack"

  providers = {
    aws = aws.eu
  }

  region_name          = "eu-west-1"
  table_name           = "greeting-logs-eu"
  cognito_user_pool_id = var.cognito_user_pool_id
  cognito_client_id    = var.cognito_client_id
}

# =====================================
# Outputs
# =====================================

output "us_api_endpoint" {
  value = module.us_east_stack.api_endpoint
}

output "eu_api_endpoint" {
  value = module.eu_west_stack.api_endpoint
}