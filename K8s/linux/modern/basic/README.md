# Kubernetes Basics - Comprehensive Learning Guide

Welcome to the foundational Kubernetes learning section! This directory contains everything you need to understand and master Kubernetes basics through a perfect blend of theory and hands-on practice.

## 🎯 Learning Objectives

By completing this section, you will:
- ✅ Understand Kubernetes architecture and core components
- ✅ Master fundamental concepts: Clusters, Nodes, Pods, Services
- ✅ Create and manage local Kubernetes clusters using Kind
- ✅ Write and deploy YAML manifests
- ✅ Use kubectl for cluster management
- ✅ Troubleshoot common issues

## 📚 Learning Structure

```
basic/
├── docs/          # 📖 Theoretical Foundation
│   ├── 01-architecture.md
│   ├── 02-core-concepts.md
│   ├── 03-objects-and-api.md
│   └── 04-networking-basics.md
│
└── practical/     # 🧪 Hands-on Implementation
    └── lab/
        ├── lab1/  # Environment Setup & Basic Operations
        └── lab2/  # Advanced Deployments & Services
```

## 🚀 Recommended Learning Path

### Phase 1: Theory Foundation (30 minutes)
1. Read `docs/01-architecture.md` → Understand the big picture
2. Study `docs/02-core-concepts.md` → Learn key components
3. Review `docs/03-objects-and-api.md` → Understand Kubernetes API
4. Optional: `docs/04-networking-basics.md` → Network fundamentals

### Phase 2: Practical Implementation (2-3 hours)
1. Complete `practical/lab/lab1/` → Setup and basics
2. Complete `practical/lab/lab2/` → Advanced concepts

### Phase 3: Integration (30 minutes)
1. Review what you've learned
2. Connect theory with practice
3. Plan next learning steps

## 📋 Prerequisites

### Knowledge Prerequisites
- Basic Linux command line skills
- Understanding of containers (Docker basics)
- Text editor familiarity (nano, vim, or VS Code)

### System Prerequisites
- Linux environment (Ubuntu 20.04+)
- 4GB RAM (8GB recommended)
- 20GB free disk space
- Internet connection

## 🛠️ Tools You'll Use

| Tool | Purpose | Installation |
|------|---------|--------------|
| **Docker** | Container runtime | `sudo apt install docker.io` |
| **kubectl** | Kubernetes CLI | Download from k8s.io |
| **Kind** | Local K8s clusters | Download binary |
| **curl** | API testing | Usually pre-installed |

## 📖 Key Concepts Covered

### Architecture & Components
- **Cluster** → The complete Kubernetes system
- **Control Plane** → The brain (API server, etcd, scheduler)
- **Worker Nodes** → Where your applications run
- **kubelet** → Node agent that manages containers

### Workload Objects
- **Pods** → Smallest deployable units
- **Deployments** → Manage replica sets of Pods
- **Services** → Expose applications to network traffic
- **Namespaces** → Logical cluster partitioning

### Configuration & Management
- **YAML Manifests** → Declarative configuration
- **Labels & Selectors** → Object identification and grouping
- **kubectl** → Command-line administration tool

## 🎯 Success Metrics

You'll know you've mastered the basics when you can:
- [ ] Explain Kubernetes architecture to someone else
- [ ] Create a Kind cluster from scratch
- [ ] Write YAML files for Pods, Services, and Deployments
- [ ] Debug Pod startup issues
- [ ] Scale applications up and down
- [ ] Understand kubectl output and logs

## 🚀 Quick Start

If you're ready to dive in:

1. **Start with Theory**: `cd docs/` and read `01-architecture.md`
2. **Jump to Practice**: `cd practical/lab/lab1/` and follow the README
3. **Get Help**: Each directory has detailed documentation and examples

## 📁 Directory Navigation

| Directory | Focus | Time Investment |
|-----------|--------|-----------------|
| [`docs/`](./docs/) | Theoretical understanding | 30-45 minutes |
| [`practical/lab/lab1/`](./practical/lab/lab1/) | Setup and basic operations | 1-1.5 hours |
| [`practical/lab/lab2/`](./practical/lab/lab2/) | Advanced concepts | 1-2 hours |

---

**🎓 Learning Tip**: Don't try to memorize everything. Focus on understanding the concepts and relationships. The specific commands will become natural with practice.

**🚀 Ready to Start?** Head to the `docs/` folder to build your theoretical foundation, then practice in the labs!
