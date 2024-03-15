data "spacelift_current_stack" "this" {}

data "spacelift_stack" "ansible" {
  stack_id = "spacelift-ansible"
}

resource "spacelift_stack_dependency" "ansible" {
  stack_id            = data.spacelift_stack.ansible.id
  depends_on_stack_id = data.spacelift_current_stack.this.id
}

resource "spacelift_stack_dependency_reference" "instances" {
  stack_dependency_id = spacelift_stack_dependency.ansible.id
  output_name         = "aws_instances"
  input_name          = "instances"
}

resource "spacelift_stack_dependency_reference" "private_key" {
  stack_dependency_id = spacelift_stack_dependency.ansible.id
  output_name         = "private_key"
  input_name          = "private_key"
}
