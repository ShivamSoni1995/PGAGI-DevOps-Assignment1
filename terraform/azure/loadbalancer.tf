# Azure Load Balancer Configuration

#######################################
# Backend Load Balancer
#######################################

# Public IP for Backend Load Balancer
resource "azurerm_public_ip" "backend_lb" {
  name                = "${local.name_prefix}-backend-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Backend Load Balancer
resource "azurerm_lb" "backend" {
  name                = "${local.name_prefix}-backend-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "backend-frontend"
    public_ip_address_id = azurerm_public_ip.backend_lb.id
  }
}

# Backend Pool for Backend Services
resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.backend.id
  name            = "backend-pool"
}

# Backend Pool Address - Instance 1
resource "azurerm_lb_backend_address_pool_address" "backend_1" {
  name                    = "backend-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_container_group.backend_1.ip_address
}

# Backend Pool Address - Instance 2
resource "azurerm_lb_backend_address_pool_address" "backend_2" {
  name                    = "backend-2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_container_group.backend_2.ip_address
}

# Health Probe for Backend
resource "azurerm_lb_probe" "backend" {
  loadbalancer_id     = azurerm_lb.backend.id
  name                = "backend-health-probe"
  protocol            = "Http"
  port                = 8000
  request_path        = "/health"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rule for Backend
resource "azurerm_lb_rule" "backend" {
  loadbalancer_id                = azurerm_lb.backend.id
  name                           = "backend-rule"
  protocol                       = "Tcp"
  frontend_port                  = 8000
  backend_port                   = 8000
  frontend_ip_configuration_name = "backend-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
  probe_id                       = azurerm_lb_probe.backend.id
  enable_tcp_reset               = true
  idle_timeout_in_minutes        = 4
}

#######################################
# Frontend Load Balancer
#######################################

# Public IP for Frontend Load Balancer
resource "azurerm_public_ip" "frontend_lb" {
  name                = "${local.name_prefix}-frontend-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Frontend Load Balancer
resource "azurerm_lb" "frontend" {
  name                = "${local.name_prefix}-frontend-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "frontend-frontend"
    public_ip_address_id = azurerm_public_ip.frontend_lb.id
  }
}

# Backend Pool for Frontend Services
resource "azurerm_lb_backend_address_pool" "frontend" {
  loadbalancer_id = azurerm_lb.frontend.id
  name            = "frontend-pool"
}

# Frontend Pool Address - Instance 1
resource "azurerm_lb_backend_address_pool_address" "frontend_1" {
  name                    = "frontend-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_container_group.frontend_1.ip_address
}

# Frontend Pool Address - Instance 2
resource "azurerm_lb_backend_address_pool_address" "frontend_2" {
  name                    = "frontend-2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
  virtual_network_id      = azurerm_virtual_network.main.id
  ip_address              = azurerm_container_group.frontend_2.ip_address
}

# Health Probe for Frontend
resource "azurerm_lb_probe" "frontend" {
  loadbalancer_id     = azurerm_lb.frontend.id
  name                = "frontend-health-probe"
  protocol            = "Http"
  port                = 3000
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rule for Frontend (HTTP)
resource "azurerm_lb_rule" "frontend_http" {
  loadbalancer_id                = azurerm_lb.frontend.id
  name                           = "frontend-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 3000
  frontend_ip_configuration_name = "frontend-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.frontend.id]
  probe_id                       = azurerm_lb_probe.frontend.id
  enable_tcp_reset               = true
  idle_timeout_in_minutes        = 4
}
