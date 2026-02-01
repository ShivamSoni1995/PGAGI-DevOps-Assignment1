# Azure Container Instances Configuration

# Backend Container Group - Instance 1
resource "azurerm_container_group" "backend_1" {
  name                = "${local.name_prefix}-backend-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.private.id]
  tags                = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  image_registry_credential {
    server                    = data.azurerm_container_registry.acr.login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.aci.id
  }

  container {
    name   = "backend"
    image  = "${data.azurerm_container_registry.acr.login_server}/backend:${var.image_tag}"
    cpu    = var.backend_cpu
    memory = var.backend_memory

    ports {
      port     = 8000
      protocol = "TCP"
    }

    environment_variables = {
      "ENVIRONMENT"     = var.environment
      "ALLOWED_ORIGINS" = var.allowed_origins
    }

    liveness_probe {
      http_get {
        path   = "/health"
        port   = 8000
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 10
      failure_threshold     = 3
    }

    readiness_probe {
      http_get {
        path   = "/health"
        port   = 8000
        scheme = "Http"
      }
      initial_delay_seconds = 5
      period_seconds        = 5
      failure_threshold     = 3
    }
  }

  depends_on = [azurerm_role_assignment.acr_pull]
}

# Backend Container Group - Instance 2
resource "azurerm_container_group" "backend_2" {
  name                = "${local.name_prefix}-backend-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.private.id]
  tags                = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  image_registry_credential {
    server                    = data.azurerm_container_registry.acr.login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.aci.id
  }

  container {
    name   = "backend"
    image  = "${data.azurerm_container_registry.acr.login_server}/backend:${var.image_tag}"
    cpu    = var.backend_cpu
    memory = var.backend_memory

    ports {
      port     = 8000
      protocol = "TCP"
    }

    environment_variables = {
      "ENVIRONMENT"     = var.environment
      "ALLOWED_ORIGINS" = var.allowed_origins
    }

    liveness_probe {
      http_get {
        path   = "/health"
        port   = 8000
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 10
      failure_threshold     = 3
    }

    readiness_probe {
      http_get {
        path   = "/health"
        port   = 8000
        scheme = "Http"
      }
      initial_delay_seconds = 5
      period_seconds        = 5
      failure_threshold     = 3
    }
  }

  depends_on = [azurerm_role_assignment.acr_pull]
}

# Frontend Container Group - Instance 1
resource "azurerm_container_group" "frontend_1" {
  name                = "${local.name_prefix}-frontend-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.private.id]
  tags                = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  image_registry_credential {
    server                    = data.azurerm_container_registry.acr.login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.aci.id
  }

  container {
    name   = "frontend"
    image  = "${data.azurerm_container_registry.acr.login_server}/frontend:${var.image_tag}"
    cpu    = var.frontend_cpu
    memory = var.frontend_memory

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      "NODE_ENV"            = "production"
      "NEXT_PUBLIC_API_URL" = "http://${azurerm_public_ip.backend_lb.ip_address}:8000"
    }

    liveness_probe {
      http_get {
        path   = "/"
        port   = 3000
        scheme = "Http"
      }
      initial_delay_seconds = 15
      period_seconds        = 10
      failure_threshold     = 3
    }

    readiness_probe {
      http_get {
        path   = "/"
        port   = 3000
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 5
      failure_threshold     = 3
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_container_group.backend_1
  ]
}

# Frontend Container Group - Instance 2
resource "azurerm_container_group" "frontend_2" {
  name                = "${local.name_prefix}-frontend-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.private.id]
  tags                = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  image_registry_credential {
    server                    = data.azurerm_container_registry.acr.login_server
    user_assigned_identity_id = azurerm_user_assigned_identity.aci.id
  }

  container {
    name   = "frontend"
    image  = "${data.azurerm_container_registry.acr.login_server}/frontend:${var.image_tag}"
    cpu    = var.frontend_cpu
    memory = var.frontend_memory

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      "NODE_ENV"            = "production"
      "NEXT_PUBLIC_API_URL" = "http://${azurerm_public_ip.backend_lb.ip_address}:8000"
    }

    liveness_probe {
      http_get {
        path   = "/"
        port   = 3000
        scheme = "Http"
      }
      initial_delay_seconds = 15
      period_seconds        = 10
      failure_threshold     = 3
    }

    readiness_probe {
      http_get {
        path   = "/"
        port   = 3000
        scheme = "Http"
      }
      initial_delay_seconds = 10
      period_seconds        = 5
      failure_threshold     = 3
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_container_group.backend_2
  ]
}
