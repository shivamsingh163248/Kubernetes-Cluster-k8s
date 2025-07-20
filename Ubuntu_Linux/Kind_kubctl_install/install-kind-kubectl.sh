#!/bin/bash

set -e

echo "📦 Updating package list..."
sudo apt update -y

echo "📁 Installing dependencies: curl, apt-transport-https..."
sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release

# Install kubectl
echo "📥 Downloading kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "📦 Installing kubectl..."
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "✅ kubectl installed. Version:"
kubectl version --client

# Install kind
echo "📥 Downloading kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

echo "📦 Installing kind..."
chmod +x ./kind
sudo mv ./kind /usr/local/bin/

echo "✅ kind installed. Version:"
kind version

echo "🎉 Installation complete!"
echo "You can now use kubectl and kind to manage your Kubernetes clusters."
echo "For more information, visit:"
echo "https://kubernetes.io/docs/tasks/tools/"
echo "https://kind.sigs.k8s.io/docs/user/quick-start/"
echo "Happy Kubernetes managing! 🚀"