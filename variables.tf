# Input variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "server_port_http" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "server_port_ssh" {
  description = "The port the server will use for SSH requests"
  type        = number
  default     = 22
}

# Add more variables as needed
# Example:
# variable "instance_type" { 
#   description = "EC2 instance type"
#   type        = string
#   default     = "t2.micro"
# }
