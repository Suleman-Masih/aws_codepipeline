output "ecs_task_execution_role" {
  value = aws_iam_role.task_execution_role.arn
}
output "ecs_task_role" {
  value = aws_iam_role.ecs_service.arn
}
