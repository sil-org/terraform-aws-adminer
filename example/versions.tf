
terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      version = "~> 3.0"
      source  = "hashicorp/aws"
    }
    cloudflare = {
      version = "~> 3.0"
      source  = "cloudflare/cloudflare"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
  }
}
