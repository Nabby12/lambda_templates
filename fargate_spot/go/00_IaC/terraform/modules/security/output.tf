output "ecs_task_role_arn" {
  value     = aws_iam_role.ecs_task_role.arn
  sensitive = true
}

output "ecs_task_execution_role_arn" {
  value     = aws_iam_role.ecs_task_execution_role.arn
  sensitive = true
}

output "container_sg_id" {
  value     = aws_security_group.container_sg.id
  sensitive = true
}
