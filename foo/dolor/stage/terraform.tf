terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "cru-tf-remote-state"
    dynamodb_table = "terraform-state-lock"
    region         = "us-east-1"
    key            = "spacelift-test/foo/dolor/stage/terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.10.0"
    }
  }
  required_version = "~> 1.5.7"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name       = local.identifier,
      managed_by = "terraform"
      owner      = "devops-engineering-team@cru.org"
      terraform  = replace(abspath(path.root), "/^.*/(cru-terraform|default)/", "")
    }
  }
}
