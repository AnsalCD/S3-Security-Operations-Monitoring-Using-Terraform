terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# ✅ AWS Provider Configuration
provider "aws" {
  region  = var.aws_region

  # 🔥 ADD THIS (fixes your error)
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "ImageProcessingApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}