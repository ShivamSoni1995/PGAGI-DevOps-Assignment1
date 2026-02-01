# Azure Terraform Outputs

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${azurerm_public_ip.frontend_lb.ip_address}"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${azurerm_public_ip.backend_lb.ip_address}:8000"
}

output "frontend_lb_ip" {
  description = "Frontend Load Balancer Public IP"
  value       = azurerm_public_ip.frontend_lb.ip_address
}

output "backend_lb_ip" {
  description = "Backend Load Balancer Public IP"
  value       = azurerm_public_ip.backend_lb.ip_address
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "container_registry" {
  description = "Container Registry login server"
  value       = data.azurerm_container_registry.acr.login_server
}

output "backend_container_instances" {
  description = "Backend container instance names"
  value = [
    azurerm_container_group.backend_1.name,
    azurerm_container_group.backend_2.name
  ]
}

output "frontend_container_instances" {
  description = "Frontend container instance names"
  value = [
    azurerm_container_group.frontend_1.name,
    azurerm_container_group.frontend_2.name
  ]
}

output "monitoring_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}
