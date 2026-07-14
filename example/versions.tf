
terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      version = "~> 6.53"
      source  = "hashicorp/aws"
    }
    cloudflare = {
      version = "~> 5.21"
      source  = "cloudflare/cloudflare"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
  }
}
