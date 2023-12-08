#-------------------------------------
#             ECS  Cluster
#-------------------------------------

resource "aws_ecs_cluster" "default" {
  name = "${var.prefix.environment}-${var.prefix.name}-test"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-ecs-api-cluster"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
}

#-----------------------------------------
#             Task Definition
#-----------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.prefix.environment}/${var.prefix.name}/${var.task_definition.name}"

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}"
    Environment = var.prefix.environment
  }
}

resource "aws_ecs_task_definition" "default" {
  container_definitions = jsonencode([{
    name : "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}",
    image : "${var.ecr_url}:latest",
    cpu : var.task_definition.fargate_cpu,
    memory : var.task_definition.fargate_memory,
    # environment = var.environment,
    # secrets     = var.secrets,
    networkMode : "awsvpc",
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : aws_cloudwatch_log_group.this.name
        "awslogs-region" : var.aws_region,
        "awslogs-stream-prefix" : "ecs-logs"
      }
    },
    portMappings : [
      {
        "protocol" : "tcp"
        "containerPort" : var.task_definition.port,
        "hostPort" : var.task_definition.port,
      }
    ],
    essential : true,
  }])
  cpu                      = var.task_definition.fargate_cpu
  execution_role_arn       = var.execution_role_arn
  family                   = "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}"
  memory                   = var.task_definition.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  depends_on = [
    aws_ecs_cluster.default,
  ]

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.task_definition.name}"
    Environment = var.prefix.environment
  }
}
#--------------------------------------------------------
#               Service
#--------------------------------------------------------



data "aws_caller_identity" "current" {}

resource "aws_ecs_service" "default" {
  name                               = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
  cluster                            = aws_ecs_cluster.default.id
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  desired_count                      = 1
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  task_definition                    = aws_ecs_task_definition.default.arn

  load_balancer {
    container_name   = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
    container_port   = var.target_group_port
    target_group_arn = var.alb_target_group_arn
  }

  network_configuration {
    assign_public_ip = var.ecs_service.assign_public_ip
    security_groups = [
      var.ecs_tasks_sg
    ]
    subnets = var.subnet_ids
  }

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.ecs_service.name}"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
}


#-----------------------------------------------------------
# ECS AutoScaling
#-----------------------------------------------------------

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.default.name}"
  role_arn           = format("arn:aws:iam::%s:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService", data.aws_caller_identity.current.account_id)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}