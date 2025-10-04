# Lab 1 Setup Scripts and Configuration Files

This directory contains automation scripts and configuration files to help you set up your Lab 1 environment quickly.

## 📁 Directory Contents

```
setup/
├── README.md                    # This file
├── install-prerequisites.sh     # Automated tool installation
├── verify-installation.sh       # Verify all tools are working
├── create-cluster.sh           # Create and configure Kind cluster
└── cluster-info.yaml          # Cluster configuration template
```

## 🚀 Quick Setup

### Option 1: Automated Setup
Run these scripts in order for fully automated setup:

```bash
# Make scripts executable
chmod +x *.sh

# 1. Install all prerequisites
./install-prerequisites.sh

# 2. Verify installation
./verify-installation.sh

# 3. Create cluster
./create-cluster.sh
```

### Option 2: Manual Setup
Follow the main Lab 1 README.md for step-by-step manual installation.

## 📋 Prerequisites

- Ubuntu 20.04+ or Debian 10+
- sudo privileges
- Internet connectivity
- 4GB+ RAM available

## 🔧 What Gets Installed

- **Docker** → Container runtime
- **kubectl** → Kubernetes CLI
- **Kind** → Local Kubernetes clusters
- **Supporting tools** → curl, conntrack, etc.

## ⚠️ Important Notes

- These scripts require sudo privileges
- Docker group membership requires logout/login
- Scripts are tested on Ubuntu 22.04 LTS
- Always review scripts before running them

---

**🎯 Ready to Start?** Use the automated scripts above or follow the detailed instructions in the main Lab 1 README.
