# Linux-based Kubernetes Learning

This section contains all Linux-specific Kubernetes learning materials, optimized for Ubuntu/Debian environments.

## 🐧 Why Linux for Kubernetes?

Kubernetes was designed with Linux in mind:
- **Native Container Support** → Better performance and compatibility
- **Production Environment** → Most Kubernetes clusters run on Linux
- **Tool Availability** → All Kubernetes tools work seamlessly on Linux
- **Community Support** → Extensive documentation and examples

## 📁 Directory Structure

```
linux/
└── comprehensive/   # Comprehensive Kubernetes learning materials
    └── basic/       # Fundamental concepts and beginner-friendly content
```

## 🔧 Linux Prerequisites

Before starting with Kubernetes on Linux, ensure you have:

### System Requirements
- **OS**: Ubuntu 20.04+ or Debian 10+
- **RAM**: Minimum 4GB (8GB recommended)
- **CPU**: 2+ cores
- **Disk**: 20GB+ free space
- **Network**: Internet connectivity for downloading tools

### Essential Tools
- `curl` → Download tools and test APIs
- `docker` → Container runtime
- `sudo` privileges → Install and configure services

### Quick System Check
```bash
# Check OS version
lsb_release -a

# Check available resources
free -h
df -h
nproc
```

## 🚀 Next Steps

Navigate to the `comprehensive/basic/` directory to start your Kubernetes learning journey with up-to-date practices and tools.

---

**💡 Tip**: All commands and examples in this repository are tested on Ubuntu 22.04 LTS.
