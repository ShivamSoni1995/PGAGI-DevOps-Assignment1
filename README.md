# DevOps Multi-Cloud Assignment

A production-ready full-stack application with CI/CD pipeline deployed on Azure with comprehensive monitoring, security, and high availability.

![CI Pipeline](https://github.com/YOUR_USERNAME/PGAGI-DevOps-Assignment1/actions/workflows/ci.yml/badge.svg)
![CD Pipeline](https://github.com/YOUR_USERNAME/PGAGI-DevOps-Assignment1/actions/workflows/cd.yml/badge.svg)

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GitHub Actions CI/CD                               │
│    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────────────┐        │
│    │  Test   │───▶│  Build  │───▶│  Push   │───▶│     Deploy      │        │
│    │ Backend │    │ Docker  │    │ to ACR  │    │   to Azure      │        │
│    │Frontend │    │ Images  │    │         │    │                 │        │
│    └─────────┘    └─────────┘    └─────────┘    └─────────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Azure Cloud                                     │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    Virtual Network (10.0.0.0/16)                       │ │
│  │  ┌──────────────────────┐    ┌──────────────────────────────────────┐  │ │
│  │  │  Public Subnet       │    │        Private Subnet                │  │ │
│  │  │  (10.0.1.0/24)       │    │        (10.0.2.0/24)                 │  │ │
│  │  │                      │    │                                      │  │ │
│  │  │  ┌────────────────┐  │    │  ┌─────────┐  ┌─────────┐           │  │ │
│  │  │  │ Load Balancer  │──┼────┼─▶│Backend-1│  │Backend-2│           │  │ │
│  │  │  │   (Frontend)   │  │    │  └─────────┘  └─────────┘           │  │ │
│  │  │  └────────────────┘  │    │                                      │  │ │
│  │  │                      │    │  ┌──────────┐  ┌──────────┐         │  │ │
│  │  │  ┌────────────────┐  │    │  │Frontend-1│  │Frontend-2│         │  │ │
│  │  │  │ Load Balancer  │──┼────┼─▶└──────────┘  └──────────┘         │  │ │
│  │  │  │   (Backend)    │  │    │                                      │  │ │
│  │  │  └────────────────┘  │    │                                      │  │ │
│  │  └──────────────────────┘    └──────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Azure ACR  │  │  Key Vault  │  │ Log Analytics│  │   Alerts   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
.
├── backend/                    # FastAPI Backend
│   ├── app/
│   │   └── main.py            # Main FastAPI application
│   ├── tests/
│   │   └── test_main.py       # Unit tests
│   ├── Dockerfile             # Multi-stage Dockerfile
│   ├── requirements.txt       # Python dependencies
│   └── pytest.ini             # Pytest configuration
├── frontend/                   # Next.js Frontend
│   ├── pages/
│   │   └── index.js           # Main page
│   ├── e2e/
│   │   └── app.spec.js        # Playwright E2E tests
│   ├── Dockerfile             # Multi-stage Dockerfile
│   ├── package.json           # Node.js dependencies
│   ├── next.config.js         # Next.js configuration
│   └── playwright.config.js   # Playwright configuration
├── terraform/
│   └── azure/                 # Azure Infrastructure
│       ├── main.tf            # Main Terraform config
│       ├── variables.tf       # Input variables
│       ├── outputs.tf         # Output values
│       ├── network.tf         # VNet, Subnets, NSGs
│       ├── containers.tf      # Container Instances
│       ├── loadbalancer.tf    # Load Balancers
│       ├── keyvault.tf        # Azure Key Vault
│       ├── monitoring.tf      # Monitoring & Alerts
│       └── acr.tf             # Container Registry
├── .github/
│   └── workflows/
│       ├── ci.yml             # CI pipeline (develop)
│       └── cd.yml             # CD pipeline (main)
├── docs/
│   ├── SECURITY.md            # Security documentation
│   └── MONITORING.md          # Monitoring setup guide
├── docker-compose.yml         # Production compose
├── docker-compose.dev.yml     # Development compose
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 20+
- Python 3.11+
- Terraform 1.5+
- Azure CLI

### Local Development

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/PGAGI-DevOps-Assignment1.git
cd PGAGI-DevOps-Assignment1

# Option 1: Run with Docker Compose (development mode)
docker-compose -f docker-compose.dev.yml up

# Option 2: Run services manually
# Backend
cd backend
python -m venv venv
source venv/bin/activate  # Windows: .\venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Frontend (in new terminal)
cd frontend
npm install
npm run dev
```

**Access:**
- Frontend: http://localhost:3000
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Running Tests

```bash
# Backend unit tests
cd backend
pip install -r requirements.txt
pytest -v --cov=app

# Frontend E2E tests
cd frontend
npm install
npx playwright install
npm run test:e2e
```

## 🔄 Branching Strategy

```
main (production)
  │
  └── develop (integration)
        │
        ├── feature/backend-api
        ├── feature/frontend-ui
        ├── feature/terraform-infra
        └── feature/ci-cd-pipeline
```

### Workflow

1. Create feature branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature
   ```

2. Make changes and commit:
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

3. Push and create Pull Request to `develop`:
   ```bash
   git push origin feature/your-feature
   ```

4. After review and CI passes, merge to `develop`

5. Create PR from `develop` to `main` for releases

## 🐳 Docker Images

### Backend Dockerfile Features
- Multi-stage build (builder → production)
- Python 3.11 slim base image
- Non-root user (`appuser`)
- Health check endpoint
- ~150MB final image size

### Frontend Dockerfile Features
- Multi-stage build (deps → builder → production)
- Node.js 20 Alpine base image
- Non-root user (`nextjs`)
- Next.js standalone output
- ~100MB final image size

## 🔧 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check for load balancer |
| `/api/health` | GET | API health status |
| `/api/message` | GET | Get greeting message |
| `/api/message` | POST | Create new message |
| `/api/messages` | GET | List all messages |
| `/api/message/{id}` | GET | Get message by ID |
| `/api/message/{id}` | DELETE | Delete message |

## ☁️ Azure Deployment

### Infrastructure Components

| Resource | Description |
|----------|-------------|
| Resource Group | Container for all resources |
| Virtual Network | Network isolation |
| Container Instances | 2x Backend, 2x Frontend |
| Load Balancers | Traffic distribution |
| Key Vault | Secrets management |
| Log Analytics | Centralized logging |
| Application Insights | APM & tracing |

### Terraform Deployment

```bash
# Set up Azure credentials
az login

# Initialize Terraform
cd terraform/azure
terraform init

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="terraform.tfvars"
```

### Required Secrets (GitHub)

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Service principal JSON |
| `AZURE_CONTAINER_REGISTRY` | ACR login server |
| `REGISTRY_USERNAME` | ACR username |
| `REGISTRY_PASSWORD` | ACR password |
| `TF_STATE_RESOURCE_GROUP` | Terraform state RG |
| `TF_STATE_STORAGE_ACCOUNT` | Terraform state storage |
| `AZURE_RESOURCE_GROUP` | Deployment resource group |

## 📊 Monitoring & Alerting

### Dashboards

Azure Portal dashboard includes:
- CPU usage (all instances)
- Memory usage (all instances)
- Network throughput
- Health probe status

### Configured Alerts

| Alert | Condition | Notification |
|-------|-----------|--------------|
| High CPU | > 70% for 5 min | Email/Slack |
| High Memory | > 80% for 5 min | Email/Slack |

### Health Checks

- Backend: `/health` every 30s
- Frontend: `/` every 30s
- Load Balancer probes: every 5s

## 🔐 Security

### Implemented Measures

- ✅ Non-root container users
- ✅ Network segmentation (public/private subnets)
- ✅ NSG rules (least privilege)
- ✅ Secrets in Azure Key Vault
- ✅ Managed identities for ACR access
- ✅ Security headers (XSS, CORS, etc.)
- ✅ Multi-stage Docker builds
- ✅ Trivy security scanning in CI

### No Secrets In

- ❌ Git repository
- ❌ Docker images
- ❌ CI/CD logs
- ❌ Environment files in repo

See [docs/SECURITY.md](docs/SECURITY.md) for details.

## 🔄 CI/CD Pipeline

### On Push to `develop`

1. ✅ Checkout code
2. ✅ Run backend tests (pytest)
3. ✅ Run frontend E2E tests (Playwright)
4. ✅ Security scan (Trivy)
5. ✅ Build Docker images
6. ✅ Tag with Git SHA
7. ✅ Push to Azure Container Registry

### On Merge to `main`

1. ✅ All CI steps
2. ✅ Terraform plan & apply
3. ✅ Deploy to Azure Container Instances
4. ✅ Health check verification
5. ✅ Slack/Email notification

## 🔁 Load Balancing & Resiliency

### Configuration

- **Backend**: 2 instances behind Load Balancer
- **Frontend**: 2 instances behind Load Balancer
- **Health probes**: 5-second intervals
- **Unhealthy threshold**: 2 consecutive failures

### Resiliency Test

```bash
# Stop one backend instance
az container stop --name devops-assignment-prod-backend-1 \
  --resource-group devops-assignment-prod-rg

# Verify application still works
curl http://<frontend-lb-ip>/

# Traffic automatically routes to healthy instance
```

## 📝 Commit Message Convention

```
<type>(<scope>): <subject>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance
```

## 🔗 Hosted URLs

After deployment, access your application at:

| Service | URL |
|---------|-----|
| Frontend | `http://<frontend-lb-ip>` |
| Backend | `http://<backend-lb-ip>:8000` |
| API Docs | `http://<backend-lb-ip>:8000/docs` |

## 📚 Additional Documentation

- [Security Documentation](docs/SECURITY.md)
- [Monitoring Guide](docs/MONITORING.md)

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 👤 Author

DevOps Engineer - PGAGI Assignment

   ```bash
   npm run start
   # or
   yarn start
   ```

   The frontend will be available at `http://localhost:3000`

## Testing the Integration

1. Ensure both backend and frontend servers are running
2. Open the frontend in your browser (default: http://localhost:3000)
3. If everything is working correctly, you should see:
   - A status message indicating the backend is connected
   - The message from the backend: "You've successfully integrated the backend!"
   - The current backend URL being used

## API Endpoints

- `GET /api/health`: Health check endpoint
  - Returns: `{"status": "healthy", "message": "Backend is running successfully"}`

- `GET /api/message`: Get the integration message
  - Returns: `{"message": "You've successfully integrated the backend!"}`
