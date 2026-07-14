terraform {
  # Terraform 1.8 is required for cross-resource moving of resources, which is used to move the Cloudflare DNS records
  # from the old resource name (cloudflare_record) to the new resource name (cloudflare_dns_record).
  required_version = ">= 1.8"
  required_providers {
    aws = {
      version = ">= 5.77.0, < 7.0.0"
      source  = "hashicorp/aws"
    }
    cloudflare = {
      version = "~> 5.0"
      source  = "cloudflare/cloudflare"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
  }
}
