# Security Documentation

## Overview

This document outlines the security measures implemented in the DevOps Assignment infrastructure.

## IAM & Access Control

### Azure RBAC Principles

We follow the **principle of least privilege** throughout the infrastructure:

1. **Container Instance Identity**
   - User Assigned Managed Identity for ACI
   - Only `AcrPull` permission on Container Registry
   - Only `Get` and `List` permissions on Key Vault secrets

2. **Service Principal (CI/CD)**
   - Limited to specific resource group
   - Only permissions needed for deployment
   - No owner-level access

### Role Assignments

| Principal | Resource | Role |
|-----------|----------|------|
| ACI Identity | ACR | AcrPull |
| ACI Identity | Key Vault | Secret Reader |
| CI/CD Service Principal | Resource Group | Contributor |
| CI/CD Service Principal | ACR | AcrPush |

## Secrets Management

### Azure Key Vault

All sensitive configuration is stored in Azure Key Vault:

- API keys
- Database connection strings
- Third-party service credentials
- Internal service tokens

### What NOT to Store in Code

❌ **Never commit these to Git:**
- API keys or tokens
- Database passwords
- Private keys or certificates
- Connection strings
- Any credentials

✅ **Use instead:**
- Azure Key Vault references
- Environment variables from CI/CD secrets
- Managed identities where possible

### CI/CD Secrets

GitHub repository secrets used:

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CREDENTIALS` | Service principal JSON for Azure login |
| `AZURE_CONTAINER_REGISTRY` | ACR login server URL |
| `REGISTRY_USERNAME` | ACR username |
| `REGISTRY_PASSWORD` | ACR password or token |
| `TF_STATE_STORAGE_ACCOUNT` | Terraform state storage |
| `SLACK_WEBHOOK_URL` | Alert notifications (optional) |

## Network Security

### Network Segmentation

```
┌─────────────────────────────────────────────────────────┐
│                     Internet                             │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│              Public Subnet (10.0.1.0/24)                │
│              ┌─────────────────────┐                    │
│              │   Load Balancer     │                    │
│              │   (Public IP)       │                    │
│              └──────────┬──────────┘                    │
└─────────────────────────┼───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│              Private Subnet (10.0.2.0/24)               │
│                                                          │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│   │  Backend-1  │  │  Backend-2  │  │  Frontend   │     │
│   │  (Private)  │  │  (Private)  │  │  (Private)  │     │
│   └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Network Security Group Rules

#### Private Subnet (Containers)

| Direction | Port | Source | Action | Description |
|-----------|------|--------|--------|-------------|
| Inbound | 3000, 8000 | 10.0.1.0/24 | Allow | From Load Balancer |
| Inbound | * | AzureLoadBalancer | Allow | Health probes |
| Inbound | * | * | Deny | All other traffic |
| Outbound | 443 | Internet | Allow | HTTPS for images |

#### Public Subnet (Load Balancer)

| Direction | Port | Source | Action | Description |
|-----------|------|--------|--------|-------------|
| Inbound | 80 | Internet | Allow | HTTP traffic |
| Inbound | 443 | Internet | Allow | HTTPS traffic |
| Inbound | 65200-65535 | GatewayManager | Allow | Azure management |

### Container Security

1. **Non-root User**
   - All containers run as non-root users
   - Backend: `appuser`
   - Frontend: `nextjs`

2. **Read-only Filesystem** (recommended for production)
   ```yaml
   security_context:
     read_only_root_filesystem: true
   ```

3. **Resource Limits**
   - CPU and memory limits enforced
   - Prevents resource exhaustion attacks

## Image Security

### Multi-stage Builds

Both Dockerfiles use multi-stage builds to:
- Minimize final image size
- Exclude build tools from production image
- Reduce attack surface

### Image Scanning

CI/CD pipeline includes Trivy security scanning:
- Scans for known vulnerabilities
- Blocks deployment on critical findings
- Reports uploaded to GitHub Security tab

### Base Image Selection

- Using official, minimal base images
- `python:3.11-slim` for backend
- `node:20-alpine` for frontend
- Regular updates scheduled

## HTTPS/TLS

### Production Recommendations

For production deployment, configure:

1. **Custom Domain with SSL**
   ```hcl
   # Add to Azure Application Gateway
   ssl_certificate {
     name     = "ssl-cert"
     data     = filebase64("path/to/cert.pfx")
     password = var.ssl_password
   }
   ```

2. **Azure Front Door** (recommended)
   - Built-in SSL/TLS
   - DDoS protection
   - WAF integration

## Security Headers

Frontend Next.js includes security headers:

```javascript
// next.config.js
headers: [
  { key: 'X-DNS-Prefetch-Control', value: 'on' },
  { key: 'X-XSS-Protection', value: '1; mode=block' },
  { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'origin-when-cross-origin' }
]
```

## Compliance Checklist

- [ ] All secrets in Key Vault
- [ ] No secrets in Git history
- [ ] Non-root container users
- [ ] Network segmentation implemented
- [ ] RBAC with least privilege
- [ ] Security scanning in CI/CD
- [ ] HTTPS in production
- [ ] Security headers configured
- [ ] Logging and monitoring enabled
- [ ] Regular dependency updates

## Incident Response

1. **Rotate Secrets**
   ```bash
   # Regenerate ACR credentials
   az acr credential renew -n <acr-name>
   
   # Update GitHub secrets
   # Update Key Vault secrets
   ```

2. **Review Audit Logs**
   ```bash
   # Azure Activity Log
   az monitor activity-log list --resource-group <rg-name>
   ```

3. **Contact Points**
   - Security Team: security@company.com
   - On-call DevOps: oncall@company.com
