#!/bin/bash

# ============================================
# Azure Setup Script for DevOps Assignment
# ============================================
# This script creates:
# 1. Resource Group
# 2. Azure Container Registry (ACR)
# 3. Service Principal for CI/CD
# 4. Storage Account for Terraform State
# ============================================

set -e

# Configuration - MODIFY THESE VALUES
PROJECT_NAME="devopsassignment"
LOCATION="eastus"
SUBSCRIPTION_ID=""  # Will be auto-detected if empty

# Derived names (Azure naming restrictions apply)
RESOURCE_GROUP_NAME="${PROJECT_NAME}-rg"
ACR_NAME="${PROJECT_NAME}acr"  # Must be globally unique, alphanumeric only
STORAGE_ACCOUNT_NAME="${PROJECT_NAME}tfstate"  # Must be globally unique
CONTAINER_NAME="tfstate"
SP_NAME="${PROJECT_NAME}-sp-cicd"

echo "============================================"
echo "Azure DevOps Assignment Setup"
echo "============================================"

# Login check
echo ""
echo "Step 0: Checking Azure login status..."
if ! az account show &>/dev/null; then
    echo "Not logged in. Please run: az login"
    exit 1
fi

# Get subscription
if [ -z "$SUBSCRIPTION_ID" ]; then
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
fi
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo "✓ Logged in to Azure"
echo "  Subscription: $SUBSCRIPTION_NAME"
echo "  Subscription ID: $SUBSCRIPTION_ID"

# Step 1: Create Resource Group
echo ""
echo "Step 1: Creating Resource Group..."
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --output none

echo "✓ Resource Group created: $RESOURCE_GROUP_NAME"

# Step 2: Create Azure Container Registry
echo ""
echo "Step 2: Creating Azure Container Registry..."
az acr create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$ACR_NAME" \
    --sku Basic \
    --admin-enabled true \
    --output none

ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

echo "✓ Container Registry created: $ACR_NAME"
echo "  Login Server: $ACR_LOGIN_SERVER"

# Step 3: Create Storage Account for Terraform State
echo ""
echo "Step 3: Creating Storage Account for Terraform State..."
az storage account create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$STORAGE_ACCOUNT_NAME" \
    --sku Standard_LRS \
    --encryption-services blob \
    --output none

az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --auth-mode login \
    --output none 2>/dev/null || \
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --output none

echo "✓ Storage Account created: $STORAGE_ACCOUNT_NAME"

# Step 4: Create Service Principal
echo ""
echo "Step 4: Creating Service Principal for CI/CD..."

# Create SP with Contributor role on the resource group
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role Contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME" \
    --sdk-auth)

# Extract values
SP_CLIENT_ID=$(echo "$SP_OUTPUT" | grep -o '"clientId": "[^"]*' | cut -d'"' -f4)
SP_CLIENT_SECRET=$(echo "$SP_OUTPUT" | grep -o '"clientSecret": "[^"]*' | cut -d'"' -f4)
SP_TENANT_ID=$(echo "$SP_OUTPUT" | grep -o '"tenantId": "[^"]*' | cut -d'"' -f4)

# Grant ACR Push permission
az role assignment create \
    --assignee "$SP_CLIENT_ID" \
    --role "AcrPush" \
    --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.ContainerRegistry/registries/$ACR_NAME" \
    --output none

echo "✓ Service Principal created: $SP_NAME"

# Output Summary
echo ""
echo "============================================"
echo "SETUP COMPLETE!"
echo "============================================"
echo ""
echo "📋 GitHub Secrets to Configure:"
echo "================================"
echo ""
echo "Go to: https://github.com/YOUR_USERNAME/PGAGI-DevOps-Assignment1/settings/secrets/actions"
echo ""
echo "Add the following secrets:"
echo ""
echo "-------------------------------------------"
echo "Secret Name: AZURE_CREDENTIALS"
echo "Secret Value:"
echo "$SP_OUTPUT"
echo ""
echo "-------------------------------------------"
echo "Secret Name: AZURE_CONTAINER_REGISTRY"
echo "Secret Value: $ACR_LOGIN_SERVER"
echo ""
echo "-------------------------------------------"
echo "Secret Name: REGISTRY_USERNAME"
echo "Secret Value: $ACR_USERNAME"
echo ""
echo "-------------------------------------------"
echo "Secret Name: REGISTRY_PASSWORD"
echo "Secret Value: $ACR_PASSWORD"
echo ""
echo "-------------------------------------------"
echo "Secret Name: TF_STATE_RESOURCE_GROUP"
echo "Secret Value: $RESOURCE_GROUP_NAME"
echo ""
echo "-------------------------------------------"
echo "Secret Name: TF_STATE_STORAGE_ACCOUNT"
echo "Secret Value: $STORAGE_ACCOUNT_NAME"
echo ""
echo "-------------------------------------------"
echo "Secret Name: AZURE_RESOURCE_GROUP"
echo "Secret Value: $RESOURCE_GROUP_NAME"
echo ""
echo "-------------------------------------------"
echo ""
echo "📝 Terraform Variables:"
echo "========================"
echo "acr_name = \"$ACR_NAME\""
echo "resource_group_name = \"$RESOURCE_GROUP_NAME\""
echo ""
echo "🔗 Important URLs:"
echo "==================="
echo "ACR Login Server: $ACR_LOGIN_SERVER"
echo "Resource Group: https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
echo ""
echo "============================================"
echo "Save this output securely!"
echo "============================================"
