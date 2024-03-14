output "aws_instances" {
  value = [for instance in aws_instance.instances : instance.public_ip]
}