terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  # Every resource we create gets these tags, which makes it easy to find leftovers
  default_tags {
    tags = {
      Project   = "aws-devops-api"
      ManagedBy = "terraform"
    }
  }
}