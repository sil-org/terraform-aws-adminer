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
}

/*
 * Create ECS service
 */
locals {
  task_def = templatefile("${path.module}/task-definition.json",
    {
      ADMINER_DEFAULT_SERVER = var.adminer_default_server
      ADMINER_DESIGN         = var.adminer_design
      ADMINER_PLUGINS        = var.adminer_plugins
      cpu                    = var.cpu
      memory                 = var.memory
    }
  )
}

module "ecsservice" {
  source             = "github.com/silinternational/terraform-modules//aws/ecs/service-only?ref=8.13.0"
  cluster_id         = var.ecs_cluster_id
  service_name       = "adminer-${var.app_name}"
  service_env        = var.app_env
  container_def_json = local.task_def
  desired_count      = var.enable ? 1 : 0
  tg_arn             = aws_alb_target_group.adminer.arn
  lb_container_name  = "adminer"
  lb_container_port  = "8080"
  ecsServiceRole_arn = var.ecsServiceRole_arn
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
