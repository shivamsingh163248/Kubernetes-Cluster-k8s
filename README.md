# ⚙️ KIND + KUBECTL Installer for Ubuntu/Linux

This repository provides a shell script to install both **[kind](https://kind.sigs.k8s.io/)** (Kubernetes IN Docker) and **[kubectl](https://kubernetes.io/docs/tasks/tools/)** (Kubernetes CLI) on Ubuntu/Linux systems.

---

## 📂 Files Included

- `install-kind-kubectl.sh` – Shell script for automatic installation.
- `INSTALL_KIND_KUBECTL_GUIDE.md` – Step-by-step usage and explanation guide.

---

## 🚀 Quick Start

### 1️⃣ Clone or Download the Repository

```bash
git clone https://github.com/your-username/kind-kubectl-installer.git
cd kind-kubectl-installer
```

Or download the files directly from GitHub.

---

## 📝 Installation Guide

### 2️⃣ Create the Installation Script

#### Option 1: Using `nano`

```bash
nano install-kind-kubectl.sh
```

Paste the script content into the editor.

To save and exit:
- `Ctrl + O` → `Enter`
- `Ctrl + X`

#### Option 2: Using `vi` or `vim`

```bash
vi install-kind-kubectl.sh
```

- Press `i` to enter insert mode.
- Paste the script.
- Press `Esc`, then type `:wq` and press `Enter`.

---

### 3️⃣ Script Content

```bash
#!/bin/bash

set -e

# Define versions
KUBECTL_VERSION="v1.30.1"
KIND_VERSION="v0.22.0"

echo "🔧 Updating system..."
sudo apt update && sudo apt install -y curl apt-transport-https

echo "📦 Installing kubectl version $KUBECTL_VERSION..."
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo "📦 Installing kind version $KIND_VERSION..."
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

echo "✅ Installation completed!"
```

---

## ✅ Run the Script

Make it executable:

```bash
chmod +x install-kind-kubectl.sh
```

Run it:

```bash
./install-kind-kubectl.sh
```

---

## 🔍 Test the Installation

Verify versions:

```bash
kubectl version --client
kind --version
```

You should see both tools installed correctly.

---

## 📘 Full Guide

See [`INSTALL_KIND_KUBECTL_GUIDE.md`](./INSTALL_KIND_KUBECTL_GUIDE.md) for the detailed markdown-based tutorial.

---

## 🔄 Update Instructions

To upgrade versions, edit the `KUBECTL_VERSION` and `KIND_VERSION` variables in the script.

---

## 💡 Notes

- Tested on Ubuntu 20.04+
- Compatible with Debian-based distributions
- For ARM systems (e.g. Raspberry Pi), use `linux/arm64` in URLs.

---

## 🐳 Happy Clustering!

Now you’re ready to use Kubernetes locally with kind + kubectl! ☸️🐳