
terraform {
  required_version = ">= 1.2"
  required_providers {
    aws = {
      version = ">= 5.77.0, < 6.0.0"
      source  = "hashicorp/aws"
    }
    cloudflare = {
      version = ">= 3.0.0, < 5.0.0"
      source  = "cloudflare/cloudflare"
    }
  }
}
