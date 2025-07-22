# 🚀 Installing Minikube on Ubuntu/Linux

This guide provides a complete walkthrough to install **Minikube**, **kubectl**, and **Docker** on a Linux system using a single script.

---

## 📜 What is Minikube?

[Minikube](https://minikube.sigs.k8s.io/) is a tool that runs a single-node Kubernetes cluster locally. It’s ideal for development, testing, and learning.

---

## 📦 Step-by-Step Installation Guide

### 1️⃣ Create the Installation Script

You can use `nano` or `vi` to create your script file.

#### 📋 Using `nano`

```bash
nano install-minikube.sh
```

#### 📋 Using `vi`

```bash
vi install-minikube.sh
```

Paste the following content into the file:

### 📄 Script Content

```bash
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
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    echo "ℹ️  Please logout and login again to apply Docker group permissions."
fi

echo "🚀 You can now start Minikube with:"
echo "    minikube start --driver=docker"

echo "🎉 Minikube installation complete!"
```

---

### 2️⃣ Make the Script Executable

```bash
chmod +x install-minikube.sh
```

### 3️⃣ Run the Script

```bash
./install-minikube.sh
```

---

## ✅ Start Minikube

Once the script is done, start your Minikube cluster:

```bash
minikube start --driver=docker
```

> 🔒 Make sure your user is added to the Docker group and you’ve logged out/in after running the script.

---

## 🔍 Verify Your Cluster

### Get Node Info

```bash
kubectl get nodes
```

### Get Context Info

```bash
kubectl config current-context
kubectl config get-contexts
```

### Use Specific Context

```bash
kubectl get nodes --context minikube
```

### Switch to Minikube Context (if needed)

```bash
kubectl config use-context minikube
```

---

## 📎 Tips

- To delete the cluster:

```bash
minikube delete
```

- To check Minikube status:

```bash
minikube status
```

- To stop Minikube:

```bash
minikube stop
```

---

## 🐳 Happy Clustering with Minikube! ☸️🚀