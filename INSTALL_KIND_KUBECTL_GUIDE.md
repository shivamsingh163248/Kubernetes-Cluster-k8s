# 🚀 Installing `kind` and `kubectl` on Ubuntu/Linux

This guide explains how to install [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) and [kubectl](https://kubernetes.io/docs/tasks/tools/) (Kubernetes CLI) on a Linux system using a shell script.

---

## 📜 Step-by-Step Instructions

### 1️⃣ Create the Shell Script File

#### ✍️ Option 1: Using `nano` (Beginner-friendly)
```bash
nano install-kind-kubectl.sh

o save and exit in nano:

Press Ctrl + O → then press Enter to save.

Press Ctrl + X to exit the editor.

✍️ Option 2: Using vi or vim
bash
Copy
Edit
vi install-kind-kubectl.sh
To insert text:

Press i (to enter insert mode).

After pasting the script:

Press Esc

Type :wq and press Enter to write and quit.

📄 Script Content
Paste the following content into your install-kind-kubectl.sh file:

bash
Copy
Edit
#!/bin/bash

set -e

# Define versions
KUBECTL_VERSION="v1.30.1"
KIND_VERSION="v0.22.0"

echo "🔧 Updating system..."
sudo apt update && sudo apt install -y curl apt-transport-https

# Install kubectl
echo "📦 Installing kubectl version $KUBECTL_VERSION..."
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install kind
echo "📦 Installing kind version $KIND_VERSION..."
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

echo "✅ Installation completed!"
✅ Run the Script
Make the script executable:

bash
Copy
Edit
chmod +x install-kind-kubectl.sh
Then run it:

bash
Copy
Edit
./install-kind-kubectl.sh
🧪 Test the Installation
To verify everything is working correctly:

bash
Copy
Edit
kubectl version --client
kind --version
You should see the installed versions printed in your terminal.

📎 Notes
Always refer to the official websites for the latest versions:

kubectl releases

kind releases

If you're using an ARM-based system (e.g. Raspberry Pi), change the download links to use linux/arm64 instead of linux/amd64.

Happy Clustering! ☸️🐳

yaml
Copy
Edit
