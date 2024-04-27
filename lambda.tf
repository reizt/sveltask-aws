data "aws_ecr_repository" "this" {
  name = local.ecr_repository_name
}

data "aws_ecr_image" "latest" {
  repository_name = data.aws_ecr_repository.this.name
  most_recent     = true
}

variable "DYNAMODB_TABLE_NAME" { type = string }
variable "MAILER_FROM" { type = string }
variable "JWT_PUBLIC_KEY" { type = string }
variable "JWT_PRIVATE_KEY" { type = string }
variable "SENDGRID_API_KEY" { type = string }

resource "aws_lambda_function" "this" {
  function_name = "${local.app}-app"
  role          = module.lambda_role.role_arn
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.this.repository_url}:${data.aws_ecr_image.latest.image_tags[0]}"
  timeout       = 900
  memory_size   = 256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.DYNAMODB_TABLE_NAME
      MAILER_FROM         = var.MAILER_FROM
      JWT_PUBLIC_KEY      = var.JWT_PUBLIC_KEY
      JWT_PRIVATE_KEY     = var.JWT_PRIVATE_KEY
      SENDGRID_API_KEY    = var.SENDGRID_API_KEY
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
}

module "lambda_role" {
  source             = "./iam-role"
  role_name          = "${local.app}-lambda"
  policy_name        = "${local.app}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  policy             = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.lambda.arn,
      "${aws_cloudwatch_log_group.lambda.arn}:*",
    ]
  }
  statement {
    sid    = "AllowDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
    ]
    resources = [
      "${data.aws_dynamodb_table.this.arn}",
      "${data.aws_dynamodb_table.this.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendTemplatedEmail",
    ]
    resources = ["*"]
  }
}
