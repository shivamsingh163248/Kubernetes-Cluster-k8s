#!/bin/bash

set -e

echo "📦 Updating system packages..."
sudo apt update -y
sudo apt install -y curl apt-transport-https ca-certificates conntrack

echo "📥 Downloading latest Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

echo "📦 Installing Minikube..."
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

echo "✅ Minikube installed. Version:"
minikube version

echo "📥 Installing kubectl (Kubernetes CLI)..."
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "✅ kubectl installed. Version:"
kubectl version --client

echo "📦 Installing Docker (if not present)..."
if ! command -v docker &> /dev/null
then
    sudo apt install -y docker.io
    sudo usermod -aG docker $USER
    echo "ℹ️  Please logout and login again to apply Docker group permissions."
fi

echo "🚀 You can now start Minikube with:"
echo "    minikube start --driver=docker"

echo "🎉 Minikube installation complete!"


# chmod +x install-minikube.sh
# Run it:

# bash
# Copy
# Edit
# ./install-minikube.sh