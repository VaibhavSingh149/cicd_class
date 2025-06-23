terraform {
  required_providers {
    aws = {source = "hashicorp/aws"}
  }
}

provider "aws" {
  region = var.aws_region
  profile = "AdminAccess-853219709078"
}

