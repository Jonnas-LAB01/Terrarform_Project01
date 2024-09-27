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
    ami =           "ami-0e54eba7c51c234f6"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                sudo yum install -y httpd
                sudo systemctl start httpd
                echo "Hello World" | sudo tee /var/www/html/index.html
                EOF

    user_data_replace_on_change = true

    tags = {
        Name = "Terraform-Example"
    }

}

resource "aws_security_group" "instance" {

  name = "terraform-example-instance"

 ingress {
    from_port = 80  
    to_port = 80    
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]  # EC2 Instance Connect IP range
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }