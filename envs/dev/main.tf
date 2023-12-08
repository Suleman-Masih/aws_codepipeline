# Terraform setup
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"

    }
  }
}

# Provider
provider "aws" {
  region  = "ap-southeast-1"
  profile = "codora-terraform"
}
#---------------------------------------------------
#                IAM
#---------------------------------------------------
module "iam" {
  source = "../../modules/iam"
  prefix = var.prefix
}
#---------------------------------------------------
#                ALB_SG
#---------------------------------------------------
module "alb_sg" {
  source = "../../modules/alb_sg"
  sg     = var.alb_sg
  vpc_id = module.vpc.vpc_id
  prefix = var.prefix
}
#---------------------------------------------------
#                APP_SG
#---------------------------------------------------

module "app_sg" {
  source             = "../../modules/app_sg"
  vpc_id             = module.vpc.vpc_id
  prefix             = var.prefix
  alb_security_group = module.alb_sg.security_group.id
}
#---------------------------------------------------
#               VPC
#---------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"
  vpc    = var.vpc
  prefix = var.prefix
}
#----------------------------------------------------
#                ECR
#----------------------------------------------------

module "ecr" {
  source = "../../modules/ecr"
  prefix = var.prefix
  ecr    = var.ecr
}
#---------------------------------------------------
#                ALB
#---------------------------------------------------
module "api_alb" {
  source     = "../../modules/alb"
  alb_sg     = module.alb_sg.security_group.id
  subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = module.vpc.vpc_id
  alb        = var.alb.api
  prefix     = var.prefix
}
# #----------------------------------------------------
# #               ECS
# #----------------------------------------------------


module "ecs" {
  source = "../../modules/ecs"
  #cluster
  prefix = var.prefix
  #task_definition
  task_definition      = var.task_definition.api
  ecr_url              = module.ecr.ecr_url
  execution_role_arn   = module.iam.ecs_task_execution_role
  aws_region           = var.aws_region
  ecs_tasks_sg         = module.app_sg.security_group.id
  subnet_ids           = module.vpc.private_subnet_ids
  alb_target_group_arn = module.api_alb.target_group.arn
  target_group_port    = var.alb.api.target_group_port
  ecs_service          = var.ecs_service.api

}