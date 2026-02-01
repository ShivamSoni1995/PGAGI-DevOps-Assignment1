# Resource Group

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}
