/*
 * Application settings
 */
variable "adminer_default_server" {
  description = "URL of default database server"
  type        = string
  default     = "db"
}

variable "adminer_design" {
  description = "specify Adminer theme, see https://adminer.org/en#extras for options"
  type        = string
  default     = ""
}

variable "adminer_plugins" {
  description = "add Adminer plugins, see https://hub.docker.com/_/adminer/ for details"
  type        = string
  default     = ""
}

variable "app_name" {
  description = "app name, used in load balancer target group name and ecs service name"
  type        = string
  default     = "adminer"
}

variable "app_env" {
  description = "app environment (e.g. prod, stg), used in load balancer target group name and ecs task definition family name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the load balancer target group"
  type        = string
}

variable "alb_https_listener_arn" {
  description = "load balancer listener ARN for the new listener rule"
  type        = string
}

variable "alb_listener_priority" {
  description = "load balancer listener priority"
  type        = number
  default     = null
}

variable "subdomain" {
  description = "subdomain for the DNS record and listener, typically app_name + \"adminer\""
  type        = string
}

variable "cloudflare_domain" {
  description = "domain name registered with Cloudflare"
  type        = string
}

variable "ecs_cluster_id" {
  description = "cluster ID for the ECS service"
  type        = string
}

variable "ecsServiceRole_arn" {
  description = "ARN of the IAM role for the ECS service"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the application load balancer, to be assigned to the DNS record"
  type        = string
}

variable "cpu" {
  description = "The hard limit of CPU units to present for the task. It can be expressed as an integer using CPU units, for example 1024, or as a string using vCPUs, for example 1 vCPU or 1 vcpu"
  type        = number
  default     = 32
}

variable "memory" {
  description = "The hard limit of memory (in MiB) to present to the task. It can be expressed as an integer using MiB, for example 1024, or as a string using GB, for example 1GB or 1 GB"
  type        = number
  default     = 128
}

variable "enable" {
  description = "Set to 'false' to destroy the DNS record and set the ECS service 'desired_count' to 0"
  type        = bool
  default     = true
}
