output "ecs_task_execution_role" {
  value = aws_iam_role.task_execution_role.arn
}
output "ecs_task_role" {
  value = aws_iam_role.ecs_service.arn
}
output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}
output "codedeploy_role_arn" {
  value = aws_iam_role.codedeploy_ecs_role.arn
} 