# IBM Cloud API Key
variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  sensitive   = true
}

# Region
variable "region" {
  description = "IBM Cloud region where resources will be created"
  type        = string
  default     = "us-south"
}

# Zone
variable "zone" {
  description = "IBM Cloud availability zone"
  type        = string
  default     = "us-south-1"
}

# Resource Group Name
variable "resource_group_name" {
  description = "Resource group name for the resources"
  type        = string
  default     = "Default"
}

# SSH Key Configuration
# Step 2 assumes the SSH key already exists (created in Step 1: terraform/ssh-key/)
# This references the existing key by name

variable "ssh_key_name" {
  description = "Name of the existing SSH key in IBM Cloud (must match the key created in Step 1)"
  type        = string
  default     = "k3s-ssh-key"
}

# VSI Name
variable "vsi_name" {
  description = "Name of the Virtual Server Instance (will be used as prefix for all resources)"
  type        = string
  default     = "k3s-cluster"
}

# VSI Profile
variable "vsi_profile" {
  description = "Profile for the VSI (e.g., bx2-2x8, cx2-2x4)"
  type        = string
  default     = "bx2-2x8"
}

# Image Name
variable "image_name" {
  description = "Name of the OS image to use"
  type        = string
  default     = "ibm-ubuntu-22-04-3-minimal-amd64-1"
}

# User Data
variable "user_data" {
  description = "User data script to run on VSI initialization"
  type        = string
  default     = ""
}

# K3s Configuration
variable "install_k3s" {
  description = "Whether to install K3s on the VSI"
  type        = bool
  default     = true
}

variable "k3s_version" {
  description = "K3s version to install (e.g., v1.28.5+k3s1, or 'latest')"
  type        = string
  default     = "latest"
}

variable "install_helm" {
  description = "Whether to install Helm package manager"
  type        = bool
  default     = false
}

variable "install_k9s" {
  description = "Whether to install k9s (Kubernetes CLI UI)"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "List of tags to apply to resources"
  type        = list(string)
  default     = ["terraform", "vsi", "k3s"]
}
