# Variables for SSH Key Creation (Step 1)

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key edit"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "Default"
}

variable "ssh_key_name" {
  description = "Name for the SSH key in IBM Cloud"
  type        = string
  default     = "k3s-ssh-key"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["terraform", "k3s", "ssh-key"]
}