# Prerequisites and Setup Guide

This guide provides detailed instructions for setting up your environment before starting the labs.

## Table of Contents

- [Required Accounts](#required-accounts)
- [Required Tools](#required-tools)
- [Environment Setup](#environment-setup)
- [Credential Configuration](#credential-configuration)
- [Verification Steps](#verification-steps)

---

## Required Accounts

### 1. IBM Cloud Account

**Purpose:** Infrastructure provisioning and VSI deployment

**Setup Steps:**
1. Create an account at [cloud.ibm.com](https://cloud.ibm.com)
2. Verify your email address
3. Add payment method (required even for free tier)
4. Create an API key:
   - Navigate to: Manage → Access (IAM) → API keys
   - Click "Create an IBM Cloud API key"
   - Name: `logistics-labs-key`
   - Save the API key securely

**Required Permissions:**
- VPC Infrastructure Services
- Virtual Server for VPC
- Resource Group access
- IAM permissions to create service IDs

**Estimated Cost:** $20-50 for lab duration (can be cleaned up after)

---

### 2. Instana Account

**Purpose:** Application and AI agent observability

**Setup Steps:**
1. Sign up for Instana trial at [instana.com](https://www.instana.com/trial/)
2. Choose "SaaS" deployment option
3. Note your Instana tenant URL (e.g., `https://your-tenant.instana.io`)
4. Generate an agent key:
   - Navigate to: Settings → Agent Keys
   - Click "Add Agent Key"
   - Name: `logistics-k3s-cluster`
   - Save the agent key

**Required Information:**
- Tenant URL
- Agent Key
- API Token (for programmatic access)

**Trial Duration:** 14 days (sufficient for all labs)

---

### 3. webMethods Account

**Purpose:** Enterprise integration workflows (Lab 3)

**Setup Steps:**
1. Request access to webMethods.io Integration
2. Sign up at [softwareag.cloud](https://www.softwareag.cloud/)
3. Create a new project: `logistics-integration`
4. Note your tenant URL and credentials

**Required Information:**
- Tenant URL
- Username
- Password
- API credentials

**Trial Duration:** 30 days

---

## Required Tools

### 1. Terraform

**Version:** >= 1.5.0

**Installation:**

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Windows:**
```powershell
choco install terraform
```

**Verification:**
```bash
terraform version
```

---

### 2. Ansible

**Version:** >= 2.14

**Installation:**

**macOS/Linux:**
```bash
pip3 install ansible
```

**Verification:**
```bash
ansible --version
```

**Required Collections:**
```bash
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.general
```

---

### 3. kubectl

**Version:** >= 1.27

**Installation:**

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Windows:**
```powershell
choco install kubernetes-cli
```

**Verification:**
```bash
kubectl version --client
```

---

### 4. Python and Jupyter

**Version:** Python >= 3.9

**Installation:**

**macOS/Linux:**
```bash
# Install Python
brew install python3  # macOS
# or
sudo apt install python3 python3-pip  # Linux

# Install Jupyter
pip3 install jupyter jupyterlab ipykernel
```

**Required Python Packages:**
```bash
pip3 install \
  ansible \
  boto3 \
  kubernetes \
  pyyaml \
  requests \
  python-dotenv
```

**Verification:**
```bash
python3 --version
jupyter --version
```

---

### 5. Git

**Installation:**

**macOS:**
```bash
brew install git
```

**Linux:**
```bash
sudo apt install git
```

**Verification:**
```bash
git --version
```

---

### 6. Additional Tools

**curl (for API testing):**
```bash
# Usually pre-installed on macOS/Linux
curl --version
```

**jq (JSON processor):**
```bash
# macOS
brew install jq

# Linux
sudo apt install jq
```

**Postman (optional, for Lab 3):**
- Download from [postman.com](https://www.postman.com/downloads/)

---

## Environment Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd logistics-labs
```

### 2. Create Virtual Environment (Recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Directory Structure Verification

```bash
tree -L 2
```

Expected output:
```
.
├── Lab1-Infrastructure-Deployment/
├── Lab2-Observability/
├── Lab3-Enterprise-Integration/
├── data/
├── docs/
└── README.md
```

---

## Credential Configuration

### 1. IBM Cloud Credentials

Create `Lab1-Infrastructure-Deployment/terraform/terraform.tfvars`:

```hcl
# IBM Cloud Configuration
ibmcloud_api_key = "YOUR_IBM_CLOUD_API_KEY"
region           = "us-south"
resource_group   = "default"

# VSI Configuration
vsi_name         = "logistics-k3s-server"
vsi_profile      = "bx2-2x8"  # 2 vCPU, 8GB RAM
ssh_key_name     = "logistics-ssh-key"

# Network Configuration
vpc_name         = "logistics-vpc"
subnet_name      = "logistics-subnet"
security_group_name = "logistics-sg"

# Tags
tags = ["logistics", "lab", "k3s"]
```

### 2. Instana Credentials

Create `Lab1-Infrastructure-Deployment/ansible/group_vars/all.yml`:

```yaml
# Instana Configuration
instana_agent_key: "YOUR_INSTANA_AGENT_KEY"
instana_endpoint_host: "your-tenant.instana.io"
instana_endpoint_port: "443"
instana_zone: "logistics-k3s-cluster"

# Application Configuration
app_namespace: "logistics"
```

### 3. SSH Key Setup

Generate SSH key for VSI access:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/logistics-key -N ""
```

Add public key to IBM Cloud:
```bash
ibmcloud is key-create logistics-ssh-key @~/.ssh/logistics-key.pub
```

### 4. Environment Variables

Create `.env` file in repository root:

```bash
# IBM Cloud
export IBMCLOUD_API_KEY="your-api-key"
export IC_REGION="us-south"

# Instana
export INSTANA_AGENT_KEY="your-agent-key"
export INSTANA_ENDPOINT="your-tenant.instana.io"

# webMethods (Lab 3)
export WEBMETHODS_URL="your-tenant-url"
export WEBMETHODS_USERNAME="your-username"
export WEBMETHODS_PASSWORD="your-password"

# Application
export POSTGRES_PASSWORD="your-secure-password"
export JWT_SECRET_KEY="your-jwt-secret"
```

Load environment variables:
```bash
source .env
```

---

## Verification Steps

### 1. Tool Verification Script

Create and run `verify-setup.sh`:

```bash
#!/bin/bash

echo "Verifying prerequisites..."

# Check Terraform
if command -v terraform &> /dev/null; then
    echo "✓ Terraform: $(terraform version | head -n1)"
else
    echo "✗ Terraform not found"
fi

# Check Ansible
if command -v ansible &> /dev/null; then
    echo "✓ Ansible: $(ansible --version | head -n1)"
else
    echo "✗ Ansible not found"
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    echo "✓ kubectl: $(kubectl version --client --short 2>/dev/null)"
else
    echo "✗ kubectl not found"
fi

# Check Python
if command -v python3 &> /dev/null; then
    echo "✓ Python: $(python3 --version)"
else
    echo "✗ Python not found"
fi

# Check Jupyter
if command -v jupyter &> /dev/null; then
    echo "✓ Jupyter: $(jupyter --version | head -n1)"
else
    echo "✗ Jupyter not found"
fi

# Check Git
if command -v git &> /dev/null; then
    echo "✓ Git: $(git --version)"
else
    echo "✗ Git not found"
fi

echo ""
echo "Verification complete!"
```

Run verification:
```bash
chmod +x verify-setup.sh
./verify-setup.sh
```

### 2. IBM Cloud CLI Verification

```bash
# Install IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Login
ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IC_REGION

# Verify access
ibmcloud resource groups
ibmcloud is vpcs
```

### 3. Ansible Connectivity Test

```bash
ansible localhost -m ping
```

Expected output:
```
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## Common Setup Issues

### Issue: Terraform Provider Download Fails

**Solution:**
```bash
terraform init -upgrade
```

### Issue: Ansible Collection Not Found

**Solution:**
```bash
ansible-galaxy collection install kubernetes.core --force
```

### Issue: kubectl Cannot Connect

**Solution:**
```bash
# Verify kubeconfig
export KUBECONFIG=~/.kube/config
kubectl config view
```

### Issue: Python Module Import Errors

**Solution:**
```bash
pip3 install --upgrade pip
pip3 install -r requirements.txt --force-reinstall
```

---

## Security Best Practices

1. **Never commit credentials to Git:**
   ```bash
   # Add to .gitignore
   echo "*.tfvars" >> .gitignore
   echo ".env" >> .gitignore
   echo "**/*_rsa*" >> .gitignore
   ```

2. **Use environment variables for sensitive data**

3. **Rotate credentials after lab completion**

4. **Clean up cloud resources to avoid charges**

5. **Use SSH key authentication, not passwords**

---

## Resource Cleanup

After completing all labs:

```bash
# Destroy Terraform resources
cd Lab1-Infrastructure-Deployment/terraform
terraform destroy -auto-approve

# Remove SSH keys
ibmcloud is key-delete logistics-ssh-key

# Uninstall Instana agents (if needed)
kubectl delete namespace instana-agent
```

---

## Next Steps

Once all prerequisites are met:

1. ✅ Verify all tools are installed
2. ✅ Configure credentials
3. ✅ Test connectivity
4. ➡️ Proceed to [Lab 1](../Lab1-Infrastructure-Deployment/README.md)

---

## Support Resources

- **IBM Cloud Docs:** https://cloud.ibm.com/docs
- **Terraform IBM Provider:** https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs
- **Ansible Documentation:** https://docs.ansible.com/
- **Instana Documentation:** https://www.ibm.com/docs/en/instana-observability
- **K3s Documentation:** https://docs.k3s.io/
