locals {
  paths = [for path in fileset(path.module, "**/terraform.tf") : dirname(path) if path != "terraform.tf"]
}

data "spacelift_aws_integration" "spacelift" {
  name = "spacelift-role"
}

data "spacelift_stack" "root" {
  stack_id = "spacelift-infrastructure"
}

resource "spacelift_stack" "stacks" {
  for_each                     = toset(local.paths)
  administrative               = false
  autodeploy                   = false
  branch                       = "main"
  description                  = "Stack for ${each.value}"
  name                         = each.key
  project_root                 = each.value
  repository                   = "spacelift-test"
  terraform_version            = "1.5.7"
  manage_state                 = false
  terraform_smart_sanitization = true
  labels                       = ["nobackend", "feature:add_plan_pr_comment"]
}

resource "spacelift_aws_integration_attachment" "stacks" {
  for_each = spacelift_stack.stacks

  integration_id = data.spacelift_aws_integration.spacelift.integration_id
  stack_id       = each.value.id

  read  = true
  write = true
}
