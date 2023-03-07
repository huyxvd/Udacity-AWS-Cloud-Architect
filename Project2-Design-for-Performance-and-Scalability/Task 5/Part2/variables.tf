# TODO: Define the variable for aws_region
variable "aws_region" {
  description = "name of region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  default = "lambda_function_name"
}