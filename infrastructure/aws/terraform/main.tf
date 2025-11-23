terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Configure in terraform.tfvars or via environment variables
    # bucket = "kado24-terraform-state"
    # key    = "terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  account_id = data.aws_caller_identity.current.account_id
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  service_names = [
    "auth-service",
    "user-service",
    "voucher-service",
    "order-service",
    "wallet-service",
    "redemption-service",
    "merchant-service",
    "admin-portal-backend",
    "notification-service",
    "payout-service",
    "analytics-service",
    "mock-payment-service"
  ]
}

