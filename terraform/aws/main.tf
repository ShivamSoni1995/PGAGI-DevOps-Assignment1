# AWS Terraform Configuration
# Main configuration for ECS Fargate + ALB deployment

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Backend configuration for state storage
  # backend "s3" {
  #   # Provided via -backend-config in CI/CD
  # }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-${random_string.suffix.result}"
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "PGAGI-DevOps-Assignment1"
    },
    var.additional_tags
  )
}

data "aws_availability_zones" "available" {}
