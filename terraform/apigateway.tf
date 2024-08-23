resource "aws_api_gateway_rest_api" "webserver-api" {
  name        = "WebserverApi"
  description = "API to call Lambda"
}

resource "aws_api_gateway_resource" "webserver-resource" {
  rest_api_id = aws_api_gateway_rest_api.webserver-api.id
  parent_id   = aws_api_gateway_rest_api.webserver-api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "webserver-method" {
  rest_api_id   = aws_api_gateway_rest_api.webserver-api.id
  resource_id   = aws_api_gateway_resource.webserver-resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "webserver-integration" {
  rest_api_id             = aws_api_gateway_rest_api.webserver-api.id
  resource_id             = aws_api_gateway_resource.webserver-resource.id
  http_method             = aws_api_gateway_method.webserver-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.webserver_lambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.webserver-api.id
  resource_id   = aws_api_gateway_rest_api.webserver-api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.webserver-api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.webserver_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "webserver-deployment" {
  rest_api_id = aws_api_gateway_rest_api.webserver-api.id
  depends_on = [
    aws_api_gateway_integration.webserver-integration,
    aws_api_gateway_integration.lambda_root
  ]
  stage_name = "test"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.webserver_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.webserver-api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_resource" "file_resource" {
  rest_api_id = aws_api_gateway_rest_api.webserver-api.id
  parent_id   = aws_api_gateway_rest_api.webserver-api.root_resource_id
  path_part   = "file"
}

resource "aws_api_gateway_method" "file_method" {
  rest_api_id   = aws_api_gateway_rest_api.webserver-api.id
  resource_id   = aws_api_gateway_resource.file_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "file_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webserver-api.id
  resource_id             = aws_api_gateway_resource.file_resource.id
  http_method             = aws_api_gateway_method.file_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:s3:::${aws_s3_bucket.file_bucket.bucket}/*"
}

resource "aws_api_gateway_resource" "text_resource" {
  rest_api_id = aws_api_gateway_rest_api.webserver-api.id
  parent_id   = aws_api_gateway_rest_api.webserver-api.root_resource_id
  path_part   = "text"
}

resource "aws_api_gateway_method" "text_method" {
  rest_api_id   = aws_api_gateway_rest_api.webserver-api.id
  resource_id   = aws_api_gateway_resource.text_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "text_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webserver-api.id
  resource_id             = aws_api_gateway_resource.text_resource.id
  http_method             = aws_api_gateway_method.text_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.text_function.invoke_arn
}