# Output values

output "alb_dns_name" {
  description = "Provides the DNS for the ALB"
  value       = aws_lb.example.dns_name
}

output "subnets_vpc" {
 description = "List of subnet IDs in the VPC"
 value = data.aws_subnets.default.ids

}

# Add your outputs here
# Example:
# output "instance_public_ip" {
#   description = "Public IP of the EC2 instance"
#   value       = aws_instance.example.public_ip
# }
