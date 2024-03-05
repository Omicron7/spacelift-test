terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "cru-tf-remote-state"
    dynamodb_table = "terraform-state-lock"
    region         = "us-east-1"
    key            = "spacelift-test/foo/dolor/terraform.tfstate"
  }
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
  required_version = "~> 1.6.4"
}
