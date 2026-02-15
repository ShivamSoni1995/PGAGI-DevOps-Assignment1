variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
  default     = "devops-assignment"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "prod"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT gateway for private subnets"
  default     = true
}

variable "backend_container_port" {
  type        = number
  description = "Backend container port"
  default     = 8000
}

variable "frontend_container_port" {
  type        = number
  description = "Frontend container port"
  default     = 3000
}

variable "backend_task_cpu" {
  type        = string
  description = "Backend task CPU units"
  default     = "512"
}

variable "backend_task_memory" {
  type        = string
  description = "Backend task memory (MiB)"
  default     = "1024"
}

variable "frontend_task_cpu" {
  type        = string
  description = "Frontend task CPU units"
  default     = "512"
}

variable "frontend_task_memory" {
  type        = string
  description = "Frontend task memory (MiB)"
  default     = "1024"
}

variable "backend_desired_count" {
  type        = number
  description = "Backend service desired count"
  default     = 2
}

variable "frontend_desired_count" {
  type        = number
  description = "Frontend service desired count"
  default     = 2
}

variable "backend_image" {
  type        = string
  description = "Backend container image (set by CI/CD)"
  default     = "public.ecr.aws/docker/library/python:3.11-slim"
}

variable "frontend_image" {
  type        = string
  description = "Frontend container image (set by CI/CD)"
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "secrets" {
  type        = list(string)
  description = "List of Secrets Manager secret name suffixes"
  default     = ["backend", "frontend"]
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to apply to resources"
  default     = {}
}
