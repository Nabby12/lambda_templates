terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10.0"
    }
  }
  backend "s3" {
    # backend/${env}.tfbackendにて定義
    # terraform init -reconfigure -backend-config=backend/${env}.tfbackend
  }
}

provider "aws" {
  region = var.aws_region
}

module "security" {
  source = "../../modules/security"

  pj_prefix = var.pj_prefix
  env       = var.env
  vpc_id    = var.vpc_id
}

module "service" {
  source = "../../modules/service"

  aws_account_id              = var.aws_account_id
  aws_region                  = var.aws_region
  pj_prefix                   = var.pj_prefix
  env                         = var.env
  image_version               = var.image_version
  subnet1                     = var.subnet1
  subnet2                     = var.subnet2
  subnet3                     = var.subnet3
  cluster_id                  = "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:cluster/${var.pj_prefix}-cluster"
  cluster_name                = "${var.pj_prefix}-cluster"
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  container_sg_id             = module.security.container_sg_id
}
