# VSI Outputs
output "vsi_id" {
  description = "ID of the Virtual Server Instance"
  value       = ibm_is_instance.vsi.id
}

output "vsi_name" {
  description = "Name of the Virtual Server Instance"
  value       = ibm_is_instance.vsi.name
}

output "vsi_status" {
  description = "Status of the Virtual Server Instance"
  value       = ibm_is_instance.vsi.status
}

output "vsi_primary_ipv4_address" {
  description = "Primary IPv4 address of the VSI"
  value       = ibm_is_instance.vsi.primary_network_interface[0].primary_ip[0].address
}

output "vsi_floating_ip" {
  description = "Floating IP address assigned to the VSI"
  value       = ibm_is_floating_ip.vsi_fip.address
}

output "vsi_floating_ip_id" {
  description = "ID of the Floating IP"
  value       = ibm_is_floating_ip.vsi_fip.id
}

output "vsi_zone" {
  description = "Zone where the VSI is deployed"
  value       = ibm_is_instance.vsi.zone
}

output "vsi_profile" {
  description = "Profile used for the VSI"
  value       = ibm_is_instance.vsi.profile
}

output "vsi_vpc_id" {
  description = "VPC ID where the VSI is deployed"
  value       = ibm_is_instance.vsi.vpc
}

output "security_group_id" {
  description = "ID of the security group attached to the VSI"
  value       = ibm_is_security_group.vsi_security_group.id
}

output "ssh_command" {
  description = "SSH command to connect to the VSI"
  value       = "ssh root@${ibm_is_floating_ip.vsi_fip.address}"
}

# K3s Outputs
output "k3s_installed" {
  description = "Whether K3s is installed on the VSI"
  value       = var.install_k3s
}

output "k3s_version" {
  description = "K3s version installed"
  value       = var.install_k3s ? var.k3s_version : "N/A"
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig from the VSI"
  value       = var.install_k3s ? "ssh root@${ibm_is_floating_ip.vsi_fip.address} 'cat /root/kubeconfig.yaml'" : "K3s not installed"
}

output "k3s_token_command" {
  description = "Command to retrieve K3s token for adding worker nodes"
  value       = var.install_k3s ? "ssh root@${ibm_is_floating_ip.vsi_fip.address} 'cat /root/k3s-token.txt'" : "K3s not installed"
}

output "k3s_access_instructions" {
  description = "Instructions to access K3s cluster"
  value       = <<-EOT
    K3s Cluster Access Instructions:
    ================================
    
    1. SSH into the VSI:
       ssh root@${ibm_is_floating_ip.vsi_fip.address}
    
    2. Check K3s status:
       systemctl status k3s
    
    3. View cluster nodes:
       kubectl get nodes
    
    4. View all pods:
       kubectl get pods -A
    
    5. Get kubeconfig (to use from your local machine):
       scp root@${ibm_is_floating_ip.vsi_fip.address}:/root/kubeconfig.yaml ./kubeconfig.yaml
       
       Then update the server URL:
       sed -i 's/127.0.0.1/${ibm_is_floating_ip.vsi_fip.address}/g' kubeconfig.yaml
       
       Use it:
       export KUBECONFIG=./kubeconfig.yaml
       kubectl get nodes
    
    6. K3s token location (for adding worker nodes):
       /root/k3s-token.txt
    
    Note: Wait 2-3 minutes after deployment for K3s installation to complete.
  EOT
}