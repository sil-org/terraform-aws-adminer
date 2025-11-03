
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "app"
}

variable "app_env" {
  type    = string
  default = "test"
}

variable "cloudflare_token" {
  type = string
}

variable "dns_domain" {
  type = string
}
