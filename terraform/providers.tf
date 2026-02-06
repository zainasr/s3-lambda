terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Always use the latest major version for 2026
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Default tags are a best practice for resource tracking
  default_tags {
    tags = {
      Project   = "S3-Image-Processor"
      ManagedBy = "Terraform"
      Owner     = "DevOps-Team"
    }
  }
}