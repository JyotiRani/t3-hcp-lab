# ============================================
# Step 2: VSI and K3s Deployment Configuration
# ============================================
# Note: SSH key must already exist (created in Step 1: terraform/ssh-key/)

# 1. IBM Cloud API Key (REQUIRED)
ibmcloud_api_key    = "##IBM_CLOUD_API_KEY##"

# 2. SSH Key Name (REQUIRED - must match Step 1)
ssh_key_name   = "##SSH_KEY_NAME##"

# ============================================
# OPTIONAL SETTINGS (Can use defaults)
# ============================================

# Region and Zone
region = "us-south"
zone   = "us-south-1"

# Resource Group Name
resource_group_name = "apac-ce-t3-26"

# VSI Configuration
vsi_name    = "t3-lab-vsi-joy01"
vsi_profile = "bxf-8x32"  # 8 vCPUs, 32 GB RAM

# OS Image
image_name = "ibm-ubuntu-22-04-3-minimal-amd64-1"

# K3s Configuration
install_k3s  = true
k3s_version  = "latest"
install_helm = true
install_k9s  = false

# Tags
tags = ["k3s-lab-vsi-joy01"]

