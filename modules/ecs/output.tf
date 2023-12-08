output "cluster_id" {
  value = aws_ecs_cluster.default.id
}

output "cluster_name" {
  value = aws_ecs_cluster.default.name
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.default
}
