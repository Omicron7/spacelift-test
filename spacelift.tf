locals {
  paths = [for path in fileset(path.module, "**/terraform.tf") : dirname(path) if path != "terraform.tf"]
}

resource "spacelift_stack" "stacks" {
  for_each          = toset(local.paths)
  administrative    = false
  autodeploy        = false
  branch            = "main"
  description       = "Stack for ${each.value}"
  name              = each.key
  project_root      = each.value
  repository        = "spacelift-test"
  terraform_version = "1.5.7"
}
