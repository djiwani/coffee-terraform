# Zip the orderProcessor code
data "archive_file" "order_processor" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda-orderProcessor.js"
  output_path = "${path.module}/lambda/orderProcessor.zip"
}

# Zip the orderRetrieve code
data "archive_file" "order_retrieve" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda-orderRetrieve.js"
  output_path = "${path.module}/lambda/orderRetrieve.zip"
}

# orderProcessor Lambda
resource "aws_lambda_function" "order_processor" {
  function_name    = "orderProcessor"
  filename         = data.archive_file.order_processor.output_path
  source_code_hash = data.archive_file.order_processor.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda-orderProcessor.handler"
  runtime          = "nodejs20.x"
  timeout		   = 10

  environment {
    variables = {
      TABLE_NAME = var.table_name
      SNS_TOPIC_ARN = aws_sns_topic.coffee_orders.arn
    }
  }

  tags = {
    Project = "fourallthedogs"
  }
}

# orderRetrieve Lambda
resource "aws_lambda_function" "order_retrieve" {
  function_name    = "orderRetrieve"
  filename         = data.archive_file.order_retrieve.output_path
  source_code_hash = data.archive_file.order_retrieve.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda-orderRetrieve.handler"
  runtime          = "nodejs20.x"
  timeout		   = 10

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  tags = {
    Project = "fourallthedogs"
  }
}

# Allow API Gateway to invoke orderProcessor
resource "aws_lambda_permission" "apigw_order_processor" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.coffee_api.execution_arn}/*/*"
}

# Allow API Gateway to invoke orderRetrieve
resource "aws_lambda_permission" "apigw_order_retrieve" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_retrieve.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.coffee_api.execution_arn}/*/*"
}