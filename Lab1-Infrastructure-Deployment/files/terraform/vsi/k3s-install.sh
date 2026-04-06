#!/bin/bash
set -e

# K3s Installation Script for IBM Cloud VSI
# This script installs K3s and configures it for production use

echo "=========================================="
echo "Starting K3s Installation on IBM Cloud VSI"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install required dependencies
echo "Installing dependencies..."
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release

# Set K3s version (use latest stable if not specified)
K3S_VERSION="$${K3S_VERSION:-latest}"
echo "K3s version: $K3S_VERSION"

# Install K3s
echo "Installing K3s..."
if [ "$K3S_VERSION" = "latest" ]; then
    curl -sfL https://get.k3s.io | sh -
else
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" sh -
fi

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
sleep 10

# Check K3s status
systemctl status k3s --no-pager || true

# Wait for node to be ready
echo "Waiting for node to be ready..."
timeout=300
elapsed=0
while [ $elapsed -lt $timeout ]; do
    if kubectl get nodes 2>/dev/null | grep -q "Ready"; then
        echo "Node is ready!"
        break
    fi
    echo "Waiting for node... ($elapsed/$timeout seconds)"
    sleep 5
    elapsed=$((elapsed + 5))
done

# Display K3s information
echo ""
echo "=========================================="
echo "K3s Installation Complete!"
echo "=========================================="
echo ""
echo "K3s Version:"
k3s --version
echo ""
echo "Node Status:"
kubectl get nodes
echo ""
echo "System Pods:"
kubectl get pods -A
echo ""

# Create kubeconfig directory for root user
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chmod 600 /root/.kube/config

# Save kubeconfig to a file for easy access
cp /etc/rancher/k3s/k3s.yaml /root/kubeconfig.yaml
chmod 600 /root/kubeconfig.yaml

echo "Kubeconfig saved to:"
echo "  - /root/.kube/config"
echo "  - /root/kubeconfig.yaml"
echo ""

# Display token for adding worker nodes (if needed)
K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo "K3s Node Token (for adding worker nodes):"
echo "$K3S_TOKEN" > /root/k3s-token.txt
chmod 600 /root/k3s-token.txt
echo "Token saved to: /root/k3s-token.txt"
echo ""

# Create a welcome message
cat > /etc/motd << 'EOF'
========================================
  IBM Cloud VSI with K3s
========================================

K3s is installed and running!

Quick Commands:
  kubectl get nodes          - View cluster nodes
  kubectl get pods -A        - View all pods
  kubectl cluster-info       - Cluster information
  systemctl status k3s       - K3s service status

Kubeconfig locations:
  - /root/.kube/config
  - /root/kubeconfig.yaml
  - /etc/rancher/k3s/k3s.yaml

K3s Token: /root/k3s-token.txt

Documentation:
  - K3s: https://docs.k3s.io
  - Kubectl: https://kubernetes.io/docs/reference/kubectl/

========================================
EOF

echo "=========================================="
echo "Installation Summary:"
echo "=========================================="
echo "✓ System packages updated"
echo "✓ K3s installed and running"
echo "✓ Kubectl configured"
echo "✓ Kubeconfig files created"
echo "✓ Node token saved"
echo ""
echo "You can now deploy applications to your K3s cluster!"
echo "=========================================="

# Optional: Install Helm
if [ "$${INSTALL_HELM:-false}" = "true" ]; then
    echo ""
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "✓ Helm installed"
    helm version
fi

# Optional: Install k9s (Kubernetes CLI UI)
if [ "$${INSTALL_K9S:-false}" = "true" ]; then
    echo ""
    echo "Installing k9s..."
    wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
    tar -xzf k9s_Linux_amd64.tar.gz
    mv k9s /usr/local/bin/
    rm k9s_Linux_amd64.tar.gz
    echo "✓ k9s installed"
fi

echo ""
echo "Installation complete! Enjoy your K3s cluster on IBM Cloud!"

# Made with Bob
