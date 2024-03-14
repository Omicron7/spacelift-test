data "spacelift_context" "ansible" {
  context_id = "ansible"
}

# Add mounted file to ansible stack
resource "spacelift_mounted_file" "private_key" {
  context_id    = data.spacelift_context.ansible.id
  relative_path = "id_rsa"
  content       = base64encode(tls_private_key.private_key.private_key_pem)
}
