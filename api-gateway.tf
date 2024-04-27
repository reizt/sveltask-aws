resource "aws_api_gateway_rest_api" "this" {
  name               = local.app
  binary_media_types = ["image/*"]
}

resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = data.aws_iam_policy_document.api_execute_policy.json
}

data "aws_iam_policy_document" "api_execute_policy" {
  statement {
    actions = [
      "execute-api:Invoke",
    ]
    resources = [
      aws_api_gateway_rest_api.this.execution_arn,
      "${aws_api_gateway_rest_api.this.execution_arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/api-gateway/${local.app}"
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "dev"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId = "$context.requestId",
      ip        = "$context.identity.sourceIp",
      user      = "$context.identity.user",
      userAgent = "$context.identity.userAgent",
      status    = "$context.status",
      method    = "$context.httpMethod",
      path      = "$context.resourcePath",
      latency   = "$context.requestTime",
    })
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = md5(file("${path.module}/api-gateway.tf"))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_root,
    aws_api_gateway_integration.lambda_all,
  ]
}
