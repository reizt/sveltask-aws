resource "aws_api_gateway_method" "this_root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Cookie" = false
  }
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.this_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn

  request_parameters = {
    "integration.request.header.Cookie" = "method.request.header.Cookie"
  }
}

resource "aws_api_gateway_method_response" "lambda_root" {
  for_each = toset(["200", "201", "204"])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.this_root.http_method
  status_code = each.key
  response_parameters = {
    "method.response.header.Set-Cookie" : false # "Set-Cookie"
  }
}

resource "aws_api_gateway_resource" "this_all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "this_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this_all.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Cookie" = false
  }
}

resource "aws_api_gateway_integration" "lambda_all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this_all.id
  http_method = aws_api_gateway_method.this_any.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn

  request_parameters = {
    "integration.request.header.Cookie" = "method.request.header.Cookie"
  }
}

resource "aws_api_gateway_method_response" "lambda_all" {
  for_each = toset(["200", "201", "204"])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this_all.id
  http_method = aws_api_gateway_method.this_any.http_method
  status_code = each.key
  response_parameters = {
    "method.response.header.Set-Cookie" : false # "Set-Cookie"
  }
}
