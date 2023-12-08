resource "aws_codedeploy_app" "codedeploy_app" {
  name = "${var.prefix.environment}-${var.prefix.name}-codedeploy"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "deployment-group"
  service_role_arn      = var.codedeploy_role
  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }
}