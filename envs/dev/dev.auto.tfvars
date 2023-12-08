prefix = {
  name        = "test-app"
  environment = "dev"
}

vpc = {
  vpc_cidr_block  = "10.0.0.0/16"
  public_subnets  = ["10.0.0.0/24", "10.0.8.0/24"]
  private_subnets = ["10.0.40.0/24", "10.0.48.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}

alb_sg = {
  name        = "alb-sg"
  description = "alb security group"
  ingress_rules = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic from internet"
    },
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic from internet"
    }
  ]

  egress_rules = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = ""
    }
  ]
}

alb = {
  api = {
    name = "api"
    # certificate_arn            = "arn:aws:acm:us-east-1:443720244737:certificate/95ce72ab-adc2-4a37-8e2d-22a77caed62a"
    target_group_port          = 8000
    internal                   = false
    load_balancer_type         = "application"
    enable_deletion_protection = false
    health_check = {
      healthy_threshold   = "3"
      interval            = "30"
      protocol            = "HTTP"
      matcher             = "200"
      timeout             = "3"
      path                = "/" # "Http path for task health check"
      unhealthy_threshold = "2"
    }
  }
}

ecr = {
  name         = "api"
  rulePriority = 1
  description  = "keep last 5 images"
  countType    = "imageCountMoreThan"
  countNumber  = 5
}

ecs_service = {
  api = {
    name                              = "api"
    assign_public_ip                  = true
    desired_count                     = 1
    health_check_grace_period_seconds = 300
    autoscaling_min_capacity          = 1
    autoscaling_max_capacity          = 10
    autoscaling_scale_down_adjustment = -1
    autoscaling_scale_down_cooldown   = 300
    autoscaling_scale_up_adjustment   = 1
    autoscaling_scale_up_cooldown     = 60
    cpu_threshold_to_scale_up_task    = 70
    cpu_threshold_to_scale_down_task  = 20
  }
}

task_definition = {
  api = {
    name           = "api"
    fargate_cpu    = 1024
    fargate_memory = 2048
    port           = 8000
  }
}