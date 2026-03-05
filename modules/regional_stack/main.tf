variable "region_name" {}
variable "table_name" {}
variable "cognito_user_pool_id" {}
variable "cognito_client_id" {}

# =========================================
# DynamoDB
# =========================================

resource "aws_dynamodb_table" "greeting_logs" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# =========================================
# IAM Role
# =========================================

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-${var.region_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamo_policy" {
  name = "lambda-dynamo-policy-${var.region_name}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:PutItem"]
      Resource = aws_dynamodb_table.greeting_logs.arn
    }]
  })
}

# =========================================
# Lambda Functions
# =========================================

resource "aws_lambda_function" "greeter_lambda" {
  function_name = "greeter-${var.region_name}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"

  filename         = "${path.module}/greeter.zip"
  source_code_hash = filebase64sha256("${path.module}/greeter.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.greeting_logs.name
      REGION     = var.region_name
    }
  }
}

resource "aws_lambda_function" "dispatcher_lambda" {
  function_name = "dispatcher-${var.region_name}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dispatcher.handler"
  runtime       = "nodejs16.x"

  filename         = "${path.module}/dispatcher.zip"
  source_code_hash = filebase64sha256("${path.module}/dispatcher.zip")
}

# =========================================
# API Gateway
# =========================================

resource "aws_apigatewayv2_api" "http_api" {
  name          = "regional-http-api-${var.region_name}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "greet_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.greeter_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "dispatch_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.dispatcher_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id          = aws_apigatewayv2_api.http_api.id
  name            = "cognito-authorizer-${var.region_name}"
  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

resource "aws_apigatewayv2_route" "greet_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /greet"
  target             = "integrations/${aws_apigatewayv2_integration.greet_integration.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "dispatch_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /dispatch"
  target             = "integrations/${aws_apigatewayv2_integration.dispatch_integration.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "greet_permission" {
  statement_id  = "AllowAPIGatewayInvokeGreet-${var.region_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greeter_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "dispatch_permission" {
  statement_id  = "AllowAPIGatewayInvokeDispatch-${var.region_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dispatcher_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}