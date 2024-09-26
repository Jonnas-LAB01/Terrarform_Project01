#Provider Definition
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.68.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

#Resource Definition
resource "aws_instance" "example" {
    ami =           "ami-0cf10cdf9fcd62d37"
    instance_type = "t2.micro"

    tags = {
        Name = "Terraform-Example"
    }

}