variable "aws_region" {
  default = "us-east-1"
}
#-----ECR------
variable "prefix" {}
variable "ecr" {}
variable "vpc" {}
variable "alb_sg" {}
variable "alb" {}
variable "ecs_service" {}
variable "task_definition" {}