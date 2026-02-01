# Azure Terraform Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-assignment"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = ""
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "backend_cpu" {
  description = "CPU cores for backend container"
  type        = number
  default     = 0.5
}

variable "backend_memory" {
  description = "Memory in GB for backend container"
  type        = number
  default     = 1
}

variable "frontend_cpu" {
  description = "CPU cores for frontend container"
  type        = number
  default     = 0.5
}

variable "frontend_memory" {
  description = "Memory in GB for frontend container"
  type        = number
  default     = 1
}

variable "backend_replicas" {
  description = "Number of backend container instances"
  type        = number
  default     = 2
}

variable "frontend_replicas" {
  description = "Number of frontend container instances"
  type        = number
  default     = 2
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "allowed_origins" {
  description = "Allowed CORS origins for backend"
  type        = string
  default     = "*"
}
