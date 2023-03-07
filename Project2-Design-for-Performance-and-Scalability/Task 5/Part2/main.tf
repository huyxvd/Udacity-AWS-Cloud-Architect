# best practice to point out the version if not terraform with pick latest may lead to issue
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  # version of terraform
  required_version = ">= 1.2.0"
}

# point out the provider & region use
provider "aws" {
  region = var.aws_region
}

# assum role to giving ability create lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create role
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# this allow us to zip te greet lambda.zip
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "greet_lambda.zip"
}

# create lambda resource
resource "aws_lambda_function" "greet_lambda" {
  filename      = "greet_lambda.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "greet_lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.8"

  depends_on = [
    aws_iam_role.iam_for_lambda,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.cloud_watch_log_for_lambda,
  ]

  environment {
    variables = {
      greeting = "greeting"
    }
  }
}


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "cloud_watch_log_for_lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}