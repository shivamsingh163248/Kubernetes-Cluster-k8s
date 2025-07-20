#!/bin/bash

set -e

# Define versions
KUBECTL_VERSION="v1.30.1"  # You can change this to the desired version
KIND_VERSION="v0.22.0"     # Latest as of July 2025

echo "🔧 Updating system..."
sudo apt update && sudo apt install -y curl apt-transport-https

# Install kubectl
echo "📦 Installing kubectl version $KUBECTL_VERSION..."
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify kubectl
kubectl version --client

# Install kind
echo "📦 Installing kind version $KIND_VERSION..."
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify kind
kind --version

echo "✅ Installation completed!"





# 📝 How to Use:
# Save the above script as install-kind-kubectl.sh.

# Run the following commands:

# chmod +x install-kind-kubectl.sh
# ./install-kind-kubectl.sh
