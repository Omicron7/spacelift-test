output "aws_instances" {
  value = [for instance in aws_instance.instances : instance.public_ip]
}

output "private_key" {
  value = base64encode(tls_private_key.private_key.private_key_pem)
}
