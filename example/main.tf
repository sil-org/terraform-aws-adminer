module "adminer" {
  source                 = "../"
  adminer_default_server = aws_db_instance.db_instance.address
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
  source  = "sil-org/ecs-cluster/aws"
  version = "~> 1.0"

  app_name = var.app_name
  app_env  = var.app_env
}

/*
 * Create VPC
 */
module "vpc" {
  source  = "sil-org/vpc/aws"
  version = "~> 1.1"

  app_name  = var.app_name
  app_env   = var.app_env
  aws_zones = [var.aws_region]
}

/*
 * Create application load balancer for public access
 */
module "alb" {
  source  = "sil-org/alb/aws"
  version = "~> 2.0"

  app_name        = var.app_name
  app_env         = var.app_env
  internal        = "false"
  vpc_id          = module.vpc.id
  security_groups = [module.vpc.vpc_default_sg_id]
  subnets         = module.vpc.public_subnet_ids
  certificate_arn = data.aws_acm_certificate.wildcard.arn
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

resource "aws_db_instance" "db_instance" {
  engine                  = "postgres"
  allocated_storage       = "8"
  instance_class          = "db.t2.micro"
  username                = "adminer-test-user"
  password                = random_id.db_root_pass.hex
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  storage_type            = "gp2"
  availability_zone       = var.aws_region
  backup_retention_period = 1
  vpc_security_group_ids  = [module.vpc.vpc_default_sg_id]
}
