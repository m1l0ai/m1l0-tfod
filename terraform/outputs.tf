output "cluster_id" {
  description = "ECS cluster id"
  value       = module.ecs.this_ecs_cluster_id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.this_ecs_cluster_name
}

output "task_definition" {
  description = "Task definition arn"
  value       = aws_ecs_task_definition.tfod_task_definition.arn
}

output "region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

output "profile" {
  description = "AWS Profile"
  value       = var.aws_profile
  sensitive   = true
}

output "log_group" {
  description = "Cloudwatch Log Group name"
  value = aws_cloudwatch_log_group.main.name
}
