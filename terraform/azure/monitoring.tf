# Azure Monitor and Alerting Configuration

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name_prefix}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${local.name_prefix}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = local.common_tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${local.name_prefix}-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "devops-ag"
  tags                = local.common_tags

  dynamic "email_receiver" {
    for_each = var.alert_email != "" ? [1] : []
    content {
      name                    = "email-alert"
      email_address           = var.alert_email
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.slack_webhook_url != "" ? [1] : []
    content {
      name                    = "slack-webhook"
      service_uri             = var.slack_webhook_url
      use_common_alert_schema = true
    }
  }
}

#######################################
# CPU Alerts
#######################################

# Backend CPU Alert > 70%
resource "azurerm_monitor_metric_alert" "backend_cpu" {
  name                = "${local.name_prefix}-backend-cpu-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [
    azurerm_container_group.backend_1.id,
    azurerm_container_group.backend_2.id
  ]
  description = "Alert when backend CPU usage exceeds 70% for 5 minutes"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"
  tags        = local.common_tags

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "CpuUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Frontend CPU Alert > 70%
resource "azurerm_monitor_metric_alert" "frontend_cpu" {
  name                = "${local.name_prefix}-frontend-cpu-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [
    azurerm_container_group.frontend_1.id,
    azurerm_container_group.frontend_2.id
  ]
  description = "Alert when frontend CPU usage exceeds 70% for 5 minutes"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"
  tags        = local.common_tags

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "CpuUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

#######################################
# Memory Alerts
#######################################

# Backend Memory Alert > 80%
resource "azurerm_monitor_metric_alert" "backend_memory" {
  name                = "${local.name_prefix}-backend-memory-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [
    azurerm_container_group.backend_1.id,
    azurerm_container_group.backend_2.id
  ]
  description = "Alert when backend memory usage exceeds 80% for 5 minutes"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"
  tags        = local.common_tags

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "MemoryUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80 * var.backend_memory * 1024 * 1024 * 1024 / 100  # 80% of allocated memory
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Frontend Memory Alert > 80%
resource "azurerm_monitor_metric_alert" "frontend_memory" {
  name                = "${local.name_prefix}-frontend-memory-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes = [
    azurerm_container_group.frontend_1.id,
    azurerm_container_group.frontend_2.id
  ]
  description = "Alert when frontend memory usage exceeds 80% for 5 minutes"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"
  tags        = local.common_tags

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "MemoryUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80 * var.frontend_memory * 1024 * 1024 * 1024 / 100  # 80% of allocated memory
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

#######################################
# Azure Dashboard
#######################################

resource "azurerm_portal_dashboard" "main" {
  name                = "${local.name_prefix}-dashboard"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags

  dashboard_properties = jsonencode({
    "lenses" : {
      "0" : {
        "order" : 0,
        "parts" : {
          "0" : {
            "position" : {
              "x" : 0,
              "y" : 0,
              "colSpan" : 6,
              "rowSpan" : 4
            },
            "metadata" : {
              "type" : "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "inputs" : [
                {
                  "name" : "resourceTypeMode",
                  "value" : "workspace"
                }
              ],
              "settings" : {
                "content" : {
                  "options" : {
                    "chart" : {
                      "title" : "Backend CPU Usage",
                      "titleKind" : 1,
                      "metrics" : [
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.backend_1.id
                          },
                          "name" : "CpuUsage",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        }
                      ]
                    }
                  }
                }
              }
            }
          },
          "1" : {
            "position" : {
              "x" : 6,
              "y" : 0,
              "colSpan" : 6,
              "rowSpan" : 4
            },
            "metadata" : {
              "type" : "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "inputs" : [
                {
                  "name" : "resourceTypeMode",
                  "value" : "workspace"
                }
              ],
              "settings" : {
                "content" : {
                  "options" : {
                    "chart" : {
                      "title" : "Frontend CPU Usage",
                      "titleKind" : 1,
                      "metrics" : [
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.frontend_1.id
                          },
                          "name" : "CpuUsage",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        }
                      ]
                    }
                  }
                }
              }
            }
          },
          "2" : {
            "position" : {
              "x" : 0,
              "y" : 4,
              "colSpan" : 6,
              "rowSpan" : 4
            },
            "metadata" : {
              "type" : "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "inputs" : [
                {
                  "name" : "resourceTypeMode",
                  "value" : "workspace"
                }
              ],
              "settings" : {
                "content" : {
                  "options" : {
                    "chart" : {
                      "title" : "Backend Memory Usage",
                      "titleKind" : 1,
                      "metrics" : [
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.backend_1.id
                          },
                          "name" : "MemoryUsage",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        }
                      ]
                    }
                  }
                }
              }
            }
          },
          "3" : {
            "position" : {
              "x" : 6,
              "y" : 4,
              "colSpan" : 6,
              "rowSpan" : 4
            },
            "metadata" : {
              "type" : "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "inputs" : [
                {
                  "name" : "resourceTypeMode",
                  "value" : "workspace"
                }
              ],
              "settings" : {
                "content" : {
                  "options" : {
                    "chart" : {
                      "title" : "Frontend Memory Usage",
                      "titleKind" : 1,
                      "metrics" : [
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.frontend_1.id
                          },
                          "name" : "MemoryUsage",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        }
                      ]
                    }
                  }
                }
              }
            }
          },
          "4" : {
            "position" : {
              "x" : 0,
              "y" : 8,
              "colSpan" : 6,
              "rowSpan" : 4
            },
            "metadata" : {
              "type" : "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "inputs" : [
                {
                  "name" : "resourceTypeMode",
                  "value" : "workspace"
                }
              ],
              "settings" : {
                "content" : {
                  "options" : {
                    "chart" : {
                      "title" : "Backend Network In/Out",
                      "titleKind" : 1,
                      "metrics" : [
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.backend_1.id
                          },
                          "name" : "NetworkBytesReceivedPerSecond",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        },
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.backend_1.id
                          },
                          "name" : "NetworkBytesTransmittedPerSecond",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        }
                      ]
                    }
                  }
                }
              }
            }
          },
          "5" : {
            "position" : {
              "x" : 6,
              "y" : 8,
              "colSpan" : 6,
              "rowSpan" : 4
            },
            "metadata" : {
              "type" : "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart",
              "inputs" : [
                {
                  "name" : "resourceTypeMode",
                  "value" : "workspace"
                }
              ],
              "settings" : {
                "content" : {
                  "options" : {
                    "chart" : {
                      "title" : "Frontend Network In/Out",
                      "titleKind" : 1,
                      "metrics" : [
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.frontend_1.id
                          },
                          "name" : "NetworkBytesReceivedPerSecond",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        },
                        {
                          "resourceMetadata" : {
                            "id" : azurerm_container_group.frontend_1.id
                          },
                          "name" : "NetworkBytesTransmittedPerSecond",
                          "aggregationType" : 4,
                          "namespace" : "Microsoft.ContainerInstance/containerGroups"
                        }
                      ]
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    "metadata" : {
      "model" : {
        "timeRange" : {
          "value" : {
            "relative" : {
              "duration" : 24,
              "timeUnit" : 1
            }
          },
          "type" : "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })
}

# Diagnostic Settings for Backend Container Groups
resource "azurerm_monitor_diagnostic_setting" "backend_1" {
  name                       = "${local.name_prefix}-backend-1-diag"
  target_resource_id         = azurerm_container_group.backend_1.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "backend_2" {
  name                       = "${local.name_prefix}-backend-2-diag"
  target_resource_id         = azurerm_container_group.backend_2.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic Settings for Frontend Container Groups
resource "azurerm_monitor_diagnostic_setting" "frontend_1" {
  name                       = "${local.name_prefix}-frontend-1-diag"
  target_resource_id         = azurerm_container_group.frontend_1.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "frontend_2" {
  name                       = "${local.name_prefix}-frontend-2-diag"
  target_resource_id         = azurerm_container_group.frontend_2.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
