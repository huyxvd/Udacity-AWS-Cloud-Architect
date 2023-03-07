# TODO: Define the output variable for the lambda function.
output "aws_lambda_arn" {
  description = "this will return lambda arn after provision"
  value       = aws_lambda_function.greet_lambda.arn
}