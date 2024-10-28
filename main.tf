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
# configuration options
  region = var.aws_region
}

#Resource Definition
resource "aws_launch_configuration" "example" {
  image_id        = "ami-0e54eba7c51c234f6"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from Terraform</h1>" | sudo tee /var/www/html/index.html
              EOF

  lifecycle {
    create_before_destroy = true
  }

  # Remove tags from launch configuration as they are not supported
  # Use tags in the auto scaling group resource instead
}

# Define an Auto Scaling Group (ASG) for our application
resource "aws_autoscaling_group" "example" {
  # Use the launch configuration we defined earlier
  launch_configuration = aws_launch_configuration.example.name
  
  # Set the minimum number of instances
  min_size = 2
  # Set the maximum number of instances
  max_size = 10
  # Set the desired number of instances to start with
  desired_capacity = 2
  
  # Specify the subnets where instances can be launched
  vpc_zone_identifier = data.aws_subnets.default.ids

  # specify the target group to be used
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  # Add a tag to instances launched by this ASG
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true  # Ensure the tag is added to all instances
  }

  # Ensure new instances are created before old ones are destroyed
  lifecycle {
    create_before_destroy = true
  }
}
#Load Balancer resource section configuration
resource "aws_lb" "example" {
  name                = "terraform-asg-example"
  load_balancer_type  = "application"
  subnets             = data.aws_subnets.default.ids
  security_groups     = [aws_security_group.alb.id]
}
#ALB listener configuration resource
resource "aws_lb_listener" "http" {
  load_balancer_arn  = aws_lb.example.arn
  port               = 80
  protocol           = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = "404"
    }
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
 condition {
  path_pattern {
    values = ["*"]
  }
 }
 action {
  type = "forward"
  target_group_arn = aws_lb_target_group.asg.arn
 }
}



resource "aws_lb_target_group" "asg" {
  name      = "terraform-asg-example"
  port      = var.server_port_http
  protocol  = "HTTP"
  vpc_id    = data.aws_vpc.default.id

  #health check configuration

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

### Security Groups section Resources ###


resource "aws_security_group" "instance" {

  name = "terraform-example-instance"

 ingress {
    from_port = var.server_port_http  
    to_port = var.server_port_http    
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = var.server_port_ssh
    to_port     = var.server_port_ssh
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

 resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

   # Allow inbound HTTP request

   ingress {
    from_port = var.server_port_http
    to_port   = var.server_port_http
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
 }






### Data source points of configuration ###

# Fetch information about the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch information about all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


