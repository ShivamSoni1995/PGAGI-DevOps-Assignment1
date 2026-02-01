# Azure Terraform Configuration
# Main configuration file for Azure Container Instances deployment

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }

  # Backend configuration for state storage
  backend "azurerm" {
    # Configuration provided via -backend-config in CI/CD
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local variables
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "PGAGI-DevOps-Assignment1"
  }
}

# Data source for current Azure configuration
data "azurerm_client_config" "current" {}
