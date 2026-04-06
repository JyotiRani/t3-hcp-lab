# IBM Cloud Provider Configuration
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

# Data source to get available images
data "ibm_is_image" "os_image" {
  name = var.image_name
}

# Create VPC
resource "ibm_is_vpc" "vpc" {
  name           = "${var.vsi_name}-vpc"
  resource_group = data.ibm_resource_group.resource_group.id
  tags           = var.tags
}

# Create Subnet
resource "ibm_is_subnet" "subnet" {
  name                     = "${var.vsi_name}-subnet"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone
  total_ipv4_address_count = 256
  resource_group           = data.ibm_resource_group.resource_group.id
}

# SSH Key Management - Step 2
# This assumes the SSH key already exists (created in Step 1)
# Reference the existing SSH key by name
data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}


# Security Group for VSI
resource "ibm_is_security_group" "vsi_security_group" {
  name           = "${var.vsi_name}-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.resource_group.id
}

# Security Group Rules
resource "ibm_is_security_group_rule" "vsi_sg_rule_inbound_ssh" {
  group     = ibm_is_security_group.vsi_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "vsi_sg_rule_inbound_http" {
  group     = ibm_is_security_group.vsi_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "vsi_sg_rule_inbound_https" {
  group     = ibm_is_security_group.vsi_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "vsi_sg_rule_inbound_k3s" {
  group     = ibm_is_security_group.vsi_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 6443
    port_max = 6443
  }
}

resource "ibm_is_security_group_rule" "vsi_sg_rule_inbound_nodeport" {
  group     = ibm_is_security_group.vsi_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "vsi_sg_rule_outbound_all" {
  group     = ibm_is_security_group.vsi_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Virtual Server Instance
resource "ibm_is_instance" "vsi" {
  name           = var.vsi_name
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = var.vsi_profile
  image          = data.ibm_is_image.os_image.id
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.vsi_security_group.id]
  }

  boot_volume {
    name = "${var.vsi_name}-boot-volume"
  }

  user_data = var.install_k3s ? templatefile("${path.module}/k3s-install.sh", {
    K3S_VERSION  = var.k3s_version
    INSTALL_HELM = var.install_helm
    INSTALL_K9S  = var.install_k9s
  }) : var.user_data

  tags = var.tags
}

# Floating IP for VSI
resource "ibm_is_floating_ip" "vsi_fip" {
  name           = "${var.vsi_name}-fip"
  target         = ibm_is_instance.vsi.primary_network_interface[0].id
  resource_group = data.ibm_resource_group.resource_group.id
  tags           = var.tags
}