# Input variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Add more variables as needed
# Example:
# variable "instance_type" { 
#   description = "EC2 instance type"
#   type        = string
#   default     = "t2.micro"
# }
