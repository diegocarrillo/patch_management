
provider "aws" {
    region = "us-east-1"
}
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  required_tags = {
    "Environment"    = "${var.build_environment}"
    "AutomationType" = "terraform"
    "Application-name" = "Patch management for EC2"
  }
}

module "patch" {
  source               = "./patch"
  build_environment    = "${var.build_environment}"
  core-environment     = "non-prod"
  tags                 = "${local.required_tags}"
}
