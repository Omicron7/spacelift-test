# Lookup Ansible stack
data "spacelift_stack" "ansible" {
  stack_id = "spacelift-ansible"
}

# Add mounted file to ansible stack
resource "spacelift_mounted_file" "private_key" {
  context_id    = data.spacelift_stack.ansible.id
  relative_path = "id_rsa"
  content       = tls_private_key.private_key.private_key_pem
}
