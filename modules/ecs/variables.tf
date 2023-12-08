variable "prefix" {}
variable "ecr_url" {}
variable "task_definition" {}
variable "execution_role_arn" {}
variable "aws_region" {}
# variable "environment" {}
# variable "secrets" {}

variable "ecs_tasks_sg" {}
variable "subnet_ids" {}
variable "ecs_service" {}
variable "alb_target_group_arn" {}
variable "target_group_port" {}
