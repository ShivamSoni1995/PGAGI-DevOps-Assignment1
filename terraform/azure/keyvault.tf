# Azure Key Vault for Secrets Management

resource "azurerm_key_vault" "main" {
  name                        = "${var.project_name}-kv-${random_string.suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = local.common_tags

  # Access policy for Terraform
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }

  # Access policy for Container Instances
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.aci.principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

# Store API secrets in Key Vault
resource "azurerm_key_vault_secret" "allowed_origins" {
  name         = "allowed-origins"
  value        = var.allowed_origins
  key_vault_id = azurerm_key_vault.main.id
  tags         = local.common_tags
}

# Backend API URL secret for frontend
resource "azurerm_key_vault_secret" "backend_url" {
  name         = "backend-url"
  value        = "http://${azurerm_public_ip.backend_lb.ip_address}:8000"
  key_vault_id = azurerm_key_vault.main.id
  tags         = local.common_tags

  depends_on = [azurerm_public_ip.backend_lb]
}
