# Outputs for SSH Key Creation (Step 1)

output "ssh_key_id" {
  description = "ID of the created SSH key"
  value       = ibm_is_ssh_key.ssh_key.id
}

output "ssh_key_name" {
  description = "Name of the created SSH key"
  value       = ibm_is_ssh_key.ssh_key.name
}

output "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key"
  value       = ibm_is_ssh_key.ssh_key.fingerprint
}

output "ssh_key_crn" {
  description = "CRN of the SSH key"
  value       = ibm_is_ssh_key.ssh_key.crn
}