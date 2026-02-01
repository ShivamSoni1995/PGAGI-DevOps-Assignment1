# Azure Container Registry Configuration

# Use existing ACR or create new one
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
}

# User Assigned Identity for Container Instances to pull from ACR
resource "azurerm_user_assigned_identity" "aci" {
  name                = "${local.name_prefix}-aci-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

# Role assignment for ACR pull
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aci.principal_id
}
