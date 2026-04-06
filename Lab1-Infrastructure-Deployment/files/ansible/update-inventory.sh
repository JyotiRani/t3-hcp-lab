#!/bin/bash
# Script to automatically update Ansible inventory with current floating IP from Terraform

set -e

echo "Getting floating IP from Terraform..."
cd "$(dirname "$0")/.."
FLOATING_IP=$(terraform output -raw vsi_floating_ip)

if [ -z "$FLOATING_IP" ]; then
    echo "Error: Could not get floating IP from Terraform"
    exit 1
fi

echo "Floating IP: $FLOATING_IP"

# Update inventory file
cd ansible
sed -i.bak "s/ansible_host=[0-9.]*\s/ansible_host=$FLOATING_IP /" inventory.ini

echo "✅ Inventory updated successfully!"
echo "Updated inventory.ini with IP: $FLOATING_IP"

# Test connectivity
echo ""
echo "Testing connectivity..."
ansible all -m ping

echo ""
echo "✅ Ready to deploy! Run: ansible-playbook deploy-microservice.yml"

# Made with Bob
