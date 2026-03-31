# The HTTP API
resource "aws_apigatewayv2_api" "coffee_api" {
  name          = "CoffeeShopAPI"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [var.allowed_origin]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = [
      "Content-Type",
      "Authorization",
      "X-Amz-Date",
      "X-Amz-Security-Token",
      "X-Amz-Content-Sha256",
      "x-amz-user-agent"
    ]
  }

  tags = {
    Project = "fourallthedogs"
  }
}

# JWT Authorizer using Cognito
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.coffee_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-admin-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.main.id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

# Integration - orderProcessor
resource "aws_apigatewayv2_integration" "order_processor" {
  api_id                 = aws_apigatewayv2_api.coffee_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.order_processor.invoke_arn
  payload_format_version = "2.0"
}

# Integration - orderRetrieve
resource "aws_apigatewayv2_integration" "order_retrieve" {
  api_id                 = aws_apigatewayv2_api.coffee_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.order_retrieve.invoke_arn
  payload_format_version = "2.0"
}

# Route - POST /order (AWS IAM auth)
resource "aws_apigatewayv2_route" "post_order" {
  api_id             = aws_apigatewayv2_api.coffee_api.id
  route_key          = "POST /order"
  authorization_type = "AWS_IAM"
  target             = "integrations/${aws_apigatewayv2_integration.order_processor.id}"
}

# Route - GET /admin/orders (JWT auth)
resource "aws_apigatewayv2_route" "get_admin_orders" {
  api_id             = aws_apigatewayv2_api.coffee_api.id
  route_key          = "GET /admin/orders"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
  target             = "integrations/${aws_apigatewayv2_integration.order_retrieve.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.coffee_api.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Project = "fourallthedogs"
  }
}

# CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/fourallthedogs-coffeeapi"
  retention_in_days = 14

  tags = {
    Project = "fourallthedogs"
  }
}
