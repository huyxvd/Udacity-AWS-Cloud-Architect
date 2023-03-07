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

# Designate a cloud provider, region, and credentials
provider "aws" {
  #access_key in my credentials file
  #secret_key in my credentials file
  region = "us-east-1"
}

# provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity_T2" {
  count = 4
  ami = "ami-0742b4e673072066f" # ami is stick with region please check if you do change the region
  instance_type = "t2.micro"

  tags = {
    Name = "Udacity T2"
  }
}

# provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "Udacity_M4" {
  # Creates 2 identical aws ec2 instances
  count = 2
  ami = "ami-0742b4e673072066f" # ami is stick with region please check if you do change the region
  instance_type = "m4.large"

  tags = {
    Name = "Udacity M4"
  }
}