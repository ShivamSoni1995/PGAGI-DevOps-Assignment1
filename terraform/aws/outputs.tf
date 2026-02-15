output "aws_region" {
  value       = var.aws_region
  description = "AWS region"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private subnet IDs"
}

output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "ALB DNS name"
}

output "alb_arn" {
  value       = aws_lb.app.arn
  description = "ALB ARN"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "ALB security group ID"
}

output "ecs_tasks_security_group_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "ECS tasks security group ID"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "ECS cluster name"
}

output "ecs_backend_service_name" {
  value       = aws_ecs_service.backend.name
  description = "Backend ECS service name"
}

output "ecs_frontend_service_name" {
  value       = aws_ecs_service.frontend.name
  description = "Frontend ECS service name"
}

output "backend_task_definition_arn" {
  value       = aws_ecs_task_definition.backend.arn
  description = "Backend task definition ARN"
}

output "frontend_task_definition_arn" {
  value       = aws_ecs_task_definition.frontend.arn
  description = "Frontend task definition ARN"
}

output "backend_task_definition_family" {
  value       = aws_ecs_task_definition.backend.family
  description = "Backend task definition family"
}

output "frontend_task_definition_family" {
  value       = aws_ecs_task_definition.frontend.family
  description = "Frontend task definition family"
}

output "backend_target_group_arn" {
  value       = aws_lb_target_group.backend.arn
  description = "Backend target group ARN"
}

output "frontend_target_group_arn" {
  value       = aws_lb_target_group.frontend.arn
  description = "Frontend target group ARN"
}

output "backend_container_name" {
  value       = local.backend_container_name
  description = "Backend container name"
}

output "frontend_container_name" {
  value       = local.frontend_container_name
  description = "Frontend container name"
}

output "backend_container_port" {
  value       = var.backend_container_port
  description = "Backend container port"
}

output "frontend_container_port" {
  value       = var.frontend_container_port
  description = "Frontend container port"
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution.arn
  description = "ECS task execution role ARN"
}

output "task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "ECS task role ARN"
}

output "secrets_manager_secret_arns" {
  value       = aws_secretsmanager_secret.app[*].arn
  description = "Secrets Manager secret ARNs"
}

output "ecr_backend_repository_url" {
  value       = aws_ecr_repository.backend.repository_url
  description = "ECR backend repository URL"
}

output "ecr_frontend_repository_url" {
  value       = aws_ecr_repository.frontend.repository_url
  description = "ECR frontend repository URL"
}
