# Step 1: SSH Key Creation Only
# This configuration creates ONLY the SSH key in IBM Cloud
# If the key already exists, this will fail gracefully and you can proceed to Step 2

terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.63.0"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# Data source to get resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Create SSH Key
# This will succeed if key doesn't exist
# This will fail if key already exists (which is fine - proceed to Step 2)
resource "ibm_is_ssh_key" "ssh_key" {
  name           = var.ssh_key_name
  public_key     = var.ssh_public_key
  resource_group = data.ibm_resource_group.resource_group.id
  tags           = var.tags
}