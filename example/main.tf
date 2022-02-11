module "adminer" {
  source                 = "../"
  adminer_default_server = module.rds.address
  app_name               = var.app_name
  app_env                = var.app_env
  vpc_id                 = module.vpc.id
  alb_https_listener_arn = module.alb.https_listener_arn
  subdomain              = "adminer"
  cloudflare_domain      = var.dns_domain
  ecs_cluster_id         = module.ecscluster.ecs_cluster_id
  ecsServiceRole_arn     = module.ecscluster.ecsServiceRole_arn
  alb_dns_name           = module.alb.dns_name
}

/*
 * Create ECS cluster
 */
module "ecscluster" {
  source   = "github.com/silinternational/terraform-modules//aws/ecs/cluster?ref=3.3.2"
  app_name = var.app_name
  app_env  = var.app_env
}

/*
 * Create VPC
 */
module "vpc" {
  source    = "github.com/silinternational/terraform-modules//aws/vpc?ref=3.3.2"
  app_name  = var.app_name
  app_env   = var.app_env
  aws_zones = [var.aws_region]
}

/*
 * Create application load balancer for public access
 */
module "alb" {
  source          = "github.com/silinternational/terraform-modules//aws/alb?ref=3.3.2"
  app_name        = var.app_name
  app_env         = var.app_env
  internal        = "false"
  vpc_id          = module.vpc.id
  security_groups = [module.vpc.vpc_default_sg_id, module.cloudflare-sg.id]
  subnets         = module.vpc.public_subnet_ids
  certificate_arn = data.aws_acm_certificate.wildcard.arn
}

/*
 * Security group to limit traffic to Cloudflare IPs
 */
module "cloudflare-sg" {
  source = "github.com/silinternational/terraform-modules//aws/cloudflare-sg?ref=3.3.2"
  vpc_id = module.vpc.id
}

/*
 * Get ssl cert for use with listener
 */
data "aws_acm_certificate" "wildcard" {
  domain = "*.${var.dns_domain}"
}

/*
 * Create RDS instance
 * root user username and password are displayed in output
 */
resource "random_id" "db_root_pass" {
  byte_length = 16
}

module "rds" {
  source                  = "github.com/silinternational/terraform-modules//aws/rds/mariadb?ref=3.3.2"
  app_name                = var.app_name
  app_env                 = var.app_env
  db_name                 = "adminer-test-db"
  db_root_user            = "adminer-test-user"
  db_root_pass            = random_id.db_root_pass.hex
  subnet_group_name       = module.vpc.db_subnet_group_name
  availability_zone       = var.aws_region
  security_groups         = [module.vpc.vpc_default_sg_id]
  engine                  = "postgres"
  engine_version          = ""
  allocated_storage       = "8"
  instance_class          = "db.t2.micro"
  storage_type            = "gp2"
  backup_retention_period = 1
  multi_az                = false
  skip_final_snapshot     = true
}
