locals {
  paths = [for path in fileset(path.module, "**/terraform.tf") : dirname(path) if path != "terraform.tf"]
}

data "spacelift_aws_integration" "spacelift" {
  name = "spacelift-role"
}

resource "spacelift_stack" "admin" {
  administrative               = true
  autodeploy                   = true
  branch                       = "main"
  description                  = "Spacelift resources required for Infrastructure deployment"
  name                         = "Spacelift Infrastructure"
  project_root                 = "/"
  protect_from_deletion        = true
  repository                   = "spacelift-test"
  terraform_version            = "1.5.7"
  manage_state                 = true
  terraform_smart_sanitization = true
  labels                       = []
  additional_project_globs     = ["*.tf"]
}

import {
  id = "spacelift-infrastructure"
  to = "spacelift_stack.admin"
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
  labels                       = ["nobackend", "feature:add_plan_pr_comment", "folder:${each.value}"]
}

resource "spacelift_aws_integration_attachment" "stacks" {
  for_each = spacelift_stack.stacks

  integration_id = data.spacelift_aws_integration.spacelift.id
  stack_id       = each.value.id

  read  = true
  write = true
}

resource "spacelift_policy" "modified_stacks_only" {
  name = "Modified Stacks Only"
  body = file("${path.module}/spacelift-policies/modified-stacks-only.rego")
  type = "GIT_PUSH"
}

resource "spacelift_policy_attachment" "stacks" {
  for_each = spacelift_stack.stacks

  policy_id = spacelift_policy.modified_stacks_only.id
  stack_id  = each.value.id
}
