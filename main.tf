/*
 * Create target group for ALB
 */
resource "aws_alb_target_group" "adminer" {
  name = replace(
    "tg-adminer-${var.app_name}-${var.app_env}",
    "/(.{0,32})(.*)/",
    "$1",
  )
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = "30"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path    = "/"
    matcher = "200"
  }
}

/*
 * Create listener rule for hostname routing to new target group
 */
resource "aws_alb_listener_rule" "adminer" {
  listener_arn = var.alb_https_listener_arn
  priority     = var.alb_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.adminer.arn
  }

  condition {
    host_header {
      values = ["${var.subdomain}.${var.cloudflare_domain}"]
    }
  }

  lifecycle {
    replace_triggered_by = [aws_alb_target_group.adminer]
  }
}

/*
 * Create ECS service
 */
locals {
  task_def = jsonencode([
    {
      cpu : var.cpu
      memory : var.memory
      image : var.require_totp ? "ghcr.io/sil-org/terraform-aws-adminer:totp" : "adminer:latest"
      name : "adminer"
      portMappings : [
        {
          "containerPort" : 8080
        },
      ]
      environment : [
        {
          "name" : "ADMINER_DEFAULT_SERVER"
          "value" : var.adminer_default_server
        },
        {
          "name" : "ADMINER_DESIGN"
          "value" : var.adminer_design
        },
        {
          "name" : "ADMINER_OTP_SECRET"
          "value" : var.require_totp ? random_bytes.totp_seed[0].base64 : ""
        },
        {
          "name" : "ADMINER_PLUGINS"
          "value" : var.adminer_plugins
        },
      ]
    }
  ])
}

module "ecsservice" {
  source  = "sil-org/ecs-service/aws"
  version = "~> 0.3.0"

  cluster_id         = var.ecs_cluster_id
  service_name       = "adminer-${var.app_name}"
  service_env        = var.app_env
  container_def_json = local.task_def
  desired_count      = var.enable ? 1 : 0
  ecsServiceRole_arn = var.ecsServiceRole_arn

  load_balancer = [{
    target_group_arn = aws_alb_target_group.adminer.arn
    container_name   = "adminer"
    container_port   = "8080"
  }]
}

/*
 * Create Cloudflare DNS record
*/
resource "cloudflare_record" "adminerdns" {
  count   = var.enable ? 1 : 0
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.subdomain
  value   = var.alb_dns_name
  type    = "CNAME"
  proxied = true
}

data "cloudflare_zones" "domain" {
  filter {
    name        = var.cloudflare_domain
    lookup_type = "exact"
    status      = "active"
  }
}

resource "random_bytes" "totp_seed" {
  count = var.require_totp ? 1 : 0

  length = 20
}

data "external" "totp_formatter" {
  count = var.require_totp ? 1 : 0

  program = ["bash", "${path.module}/totp.sh"]

  query = {
    secret_base64 = random_bytes.totp_seed[0].base64
  }
}
