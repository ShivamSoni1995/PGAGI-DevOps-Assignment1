# Monitoring Documentation

## Overview

This document describes the monitoring and alerting setup for the DevOps Assignment infrastructure on Azure.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Monitor                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────┐    ┌─────────────────┐                    │
│   │ Log Analytics   │    │ Application     │                    │
│   │ Workspace       │    │ Insights        │                    │
│   └────────┬────────┘    └────────┬────────┘                    │
│            │                      │                              │
│            └──────────┬───────────┘                              │
│                       │                                          │
│            ┌──────────▼──────────┐                               │
│            │    Azure Portal     │                               │
│            │    Dashboard        │                               │
│            └──────────┬──────────┘                               │
│                       │                                          │
│            ┌──────────▼──────────┐                               │
│            │   Metric Alerts     │                               │
│            └──────────┬──────────┘                               │
│                       │                                          │
│            ┌──────────▼──────────┐                               │
│            │   Action Groups     │                               │
│            │  (Email/Slack)      │                               │
│            └────────────────────┘                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Dashboards

### Main Dashboard

The Azure Portal dashboard includes:

1. **Backend CPU Usage**
   - Real-time CPU utilization
   - Both container instances

2. **Frontend CPU Usage**
   - Real-time CPU utilization
   - Both container instances

3. **Backend Memory Usage**
   - Memory consumption in bytes
   - Percentage of allocated memory

4. **Frontend Memory Usage**
   - Memory consumption in bytes
   - Percentage of allocated memory

5. **Network Traffic**
   - Bytes received/transmitted per second
   - Both backend and frontend

### Accessing the Dashboard

1. Go to Azure Portal
2. Navigate to **Dashboards**
3. Select `devops-assignment-prod-dashboard`

Or use the Azure CLI:
```bash
az portal dashboard show \
  --name devops-assignment-prod-dashboard \
  --resource-group devops-assignment-prod-rg
```

## Metrics Collected

### Container Metrics

| Metric | Description | Unit |
|--------|-------------|------|
| CpuUsage | CPU cores used | Cores |
| MemoryUsage | Memory used | Bytes |
| NetworkBytesReceivedPerSecond | Inbound network traffic | Bytes/sec |
| NetworkBytesTransmittedPerSecond | Outbound network traffic | Bytes/sec |

### Load Balancer Metrics

| Metric | Description | Unit |
|--------|-------------|------|
| HealthProbeStatus | Backend health status | Boolean |
| ByteCount | Total bytes processed | Bytes |
| PacketCount | Total packets processed | Count |
| SYNCount | SYN packets received | Count |

## Alerts

### Configured Alerts

| Alert Name | Condition | Severity | Window |
|------------|-----------|----------|--------|
| Backend CPU High | CPU > 70% | Warning (2) | 5 min |
| Frontend CPU High | CPU > 70% | Warning (2) | 5 min |
| Backend Memory High | Memory > 80% | Warning (2) | 5 min |
| Frontend Memory High | Memory > 80% | Warning (2) | 5 min |

### Alert Severity Levels

- **0 - Critical**: Immediate action required
- **1 - Error**: High priority issue
- **2 - Warning**: Should be investigated
- **3 - Informational**: For awareness
- **4 - Verbose**: Detailed information

### Notification Channels

1. **Email**
   - Configured in `alert_email` variable
   - Receives all alert notifications

2. **Slack** (optional)
   - Configure `slack_webhook_url` in Terraform
   - Real-time notifications to channel

### Adding New Alerts

To add a custom alert, add to `monitoring.tf`:

```hcl
resource "azurerm_monitor_metric_alert" "custom_alert" {
  name                = "${local.name_prefix}-custom-alert"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_container_group.backend_1.id]
  description         = "Description of the alert"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "MetricName"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
```

## Log Analytics

### Querying Logs

Access Log Analytics in Azure Portal or use KQL queries:

```kql
// Container CPU usage over time
ContainerInstanceLog_CL
| where TimeGenerated > ago(1h)
| summarize avg(CpuUsage_d) by bin(TimeGenerated, 5m), ContainerGroup_s
| render timechart
```

```kql
// Container errors
ContainerInstanceLog_CL
| where TimeGenerated > ago(24h)
| where Level_s == "Error"
| project TimeGenerated, ContainerGroup_s, Message_s
| order by TimeGenerated desc
```

```kql
// Memory usage trend
ContainerInstanceLog_CL
| where TimeGenerated > ago(6h)
| summarize avg(MemoryUsage_d) by bin(TimeGenerated, 10m), ContainerGroup_s
| render timechart
```

### Retention

- Default retention: 30 days
- Can be extended up to 730 days
- Configure in `azurerm_log_analytics_workspace`

## Application Insights

### Features

- Request tracking
- Dependency monitoring
- Exception logging
- Performance metrics
- Availability tests

### Integration

To enable Application Insights in containers, add:

**Backend (Python):**
```python
from opencensus.ext.azure.trace_exporter import AzureExporter
from opencensus.trace.samplers import ProbabilitySampler
from opencensus.trace.tracer import Tracer

tracer = Tracer(
    exporter=AzureExporter(
        connection_string=os.environ.get('APPLICATIONINSIGHTS_CONNECTION_STRING')
    ),
    sampler=ProbabilitySampler(1.0)
)
```

**Frontend (Next.js):**
```javascript
// Install: npm install @microsoft/applicationinsights-web
import { ApplicationInsights } from '@microsoft/applicationinsights-web';

const appInsights = new ApplicationInsights({
  config: {
    connectionString: process.env.APPLICATIONINSIGHTS_CONNECTION_STRING
  }
});
appInsights.loadAppInsights();
```

## Health Checks

### Endpoint Monitoring

| Service | Endpoint | Expected Response |
|---------|----------|-------------------|
| Backend | `/health` | `{"status": "healthy"}` |
| Frontend | `/` | HTTP 200 |

### Load Balancer Probes

- **Interval**: 5 seconds
- **Timeout**: 2 seconds
- **Unhealthy threshold**: 2 consecutive failures

## Runbooks

### High CPU Alert Response

1. Check container logs:
   ```bash
   az container logs --name <container-name> --resource-group <rg>
   ```

2. Check for traffic spikes in dashboard

3. Consider scaling:
   - Increase CPU allocation
   - Add more instances

### High Memory Alert Response

1. Check for memory leaks in application logs

2. Review recent deployments

3. Options:
   - Increase memory allocation
   - Optimize application code
   - Add more instances

### Container Unhealthy

1. Check container status:
   ```bash
   az container show --name <name> --resource-group <rg> --query instanceView
   ```

2. View logs:
   ```bash
   az container logs --name <name> --resource-group <rg>
   ```

3. Restart container:
   ```bash
   az container restart --name <name> --resource-group <rg>
   ```

## Cost Optimization

### Monitoring Costs

| Service | Estimated Cost |
|---------|---------------|
| Log Analytics | ~$2.50/GB ingested |
| Application Insights | ~$2.30/GB |
| Alerts | Free (up to 10 rules) |

### Tips

1. Set appropriate retention periods
2. Filter unnecessary logs at source
3. Use sampling for Application Insights
4. Review and disable unused alerts
