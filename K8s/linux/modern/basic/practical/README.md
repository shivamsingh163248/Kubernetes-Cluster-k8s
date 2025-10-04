# Kubernetes Practical Labs - Hands-on Learning

Welcome to the practical section of the Kubernetes learning journey! This directory contains hands-on labs designed to reinforce theoretical concepts through real-world exercises.

## 🎯 Lab Overview

### Learning Philosophy
- **Theory + Practice = Mastery** → 20% reading, 80% doing
- **Progressive Complexity** → Start simple, build complexity
- **Real-world Scenarios** → Practical examples you'll use in production
- **Troubleshooting Focus** → Learn to debug and fix issues

## 📚 Lab Structure

```
practical/
└── lab/
    ├── lab1/          # Environment Setup & Basic Operations
    │   ├── README.md  # Lab guide and instructions
    │   ├── setup/     # Setup scripts and configs
    │   ├── exercises/ # Step-by-step exercises
    │   └── solutions/ # Solution files and examples
    │
    └── lab2/          # Advanced Deployments & Services  
        ├── README.md  # Lab guide and instructions
        ├── manifests/ # YAML configuration files
        ├── exercises/ # Advanced exercises
        └── solutions/ # Complete solutions
```

## 🚀 Prerequisites

### Knowledge Requirements
- Completed reading of `../docs/` section
- Basic understanding of:
  - Kubernetes architecture
  - Core concepts (Pods, Services, Deployments)
  - YAML syntax
  - Linux command line

### System Requirements
- **OS**: Ubuntu 20.04+ or Debian 10+
- **RAM**: 4GB minimum (8GB recommended)
- **CPU**: 2+ cores
- **Disk**: 20GB+ free space
- **Network**: Internet connectivity

### Tools Needed
- Docker (container runtime)
- kubectl (Kubernetes CLI)
- Kind (Kubernetes in Docker)
- curl (API testing)
- Text editor (nano, vim, or VS Code)

## 📋 Lab Progression

### Lab 1: Environment Setup & Basic Operations
**Duration**: 1-1.5 hours  
**Difficulty**: Beginner  

**What You'll Learn**:
- Set up a local Kubernetes cluster using Kind
- Create and manage Pods using YAML
- Understand namespaces and labels
- Expose applications using Services
- Basic kubectl commands and troubleshooting

**Prerequisites**: Read all documentation in `../docs/`

### Lab 2: Advanced Deployments & Services
**Duration**: 1.5-2 hours  
**Difficulty**: Intermediate  

**What You'll Learn**:
- Create and manage Deployments
- Scale applications horizontally
- Implement rolling updates
- Advanced service configurations
- Resource management and limits
- Health checks and monitoring

**Prerequisites**: Complete Lab 1

## 🛠️ Setup Instructions

### Quick Start
1. **Verify Prerequisites**:
   ```bash
   # Check if tools are installed
   docker --version
   kubectl version --client
   kind version
   ```

2. **Start with Lab 1**:
   ```bash
   cd lab/lab1/
   cat README.md  # Read lab instructions
   ```

3. **Follow Sequential Order**:
   - Complete Lab 1 entirely before moving to Lab 2
   - Each lab builds on the previous one

### Environment Preparation
```bash
# Update system
sudo apt update -y

# Verify Docker is running
sudo systemctl status docker

# Check available resources
free -h    # Check RAM
df -h      # Check disk space
nproc      # Check CPU cores
```

## 📊 Success Metrics

### Lab 1 Completion Checklist
- [ ] Kind cluster created and running
- [ ] Successfully deployed first Pod
- [ ] Created and tested Service
- [ ] Performed basic kubectl operations
- [ ] Completed troubleshooting exercises

### Lab 2 Completion Checklist
- [ ] Created multi-replica Deployments
- [ ] Performed rolling updates
- [ ] Scaled applications up and down
- [ ] Configured resource limits
- [ ] Set up health checks

## 🔍 Troubleshooting Guide

### Common Issues

#### Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

#### Kind Cluster Won't Start
```bash
# Check Docker status
sudo systemctl status docker

# Clean up previous clusters
kind delete cluster --name mycluster
kind create cluster --name mycluster
```

#### kubectl Connection Issues
```bash
# Verify cluster context
kubectl config current-context

# Test basic connectivity
kubectl cluster-info
kubectl get nodes
```

### Getting Help

#### Documentation References
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)

#### Debug Commands
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# View system events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs -n kube-system <pod-name>
```

## 📝 Lab Guidelines

### Best Practices
- **Read Instructions Carefully** → Each step builds on the previous
- **Save Your Work** → Keep YAML files for reference
- **Experiment Freely** → Labs are designed for exploration
- **Take Notes** → Document what you learn
- **Ask Questions** → Research concepts you don't understand

### File Organization
```bash
# Suggested directory structure for your work
~/k8s-labs/
├── lab1/
│   ├── my-configs/    # Your YAML files
│   ├── notes.md       # Your learning notes
│   └── commands.sh    # Useful commands
└── lab2/
    ├── deployments/   # Deployment configs
    ├── services/      # Service configs
    └── experiments/   # Testing configurations
```

## 🎯 Learning Outcomes

After completing these labs, you will:
- **Confidently create** Kubernetes clusters locally
- **Write effective** YAML manifests for various objects
- **Troubleshoot common issues** using kubectl and logs
- **Understand networking** and service discovery
- **Manage application lifecycle** through deployments
- **Apply resource management** best practices

## 🚀 Next Steps After Labs

### Intermediate Learning Path
1. **Persistent Storage** → StatefulSets, Volumes, PVCs
2. **Configuration Management** → ConfigMaps, Secrets
3. **Security** → RBAC, Network Policies, Pod Security
4. **Monitoring** → Prometheus, Grafana, Logging
5. **CI/CD Integration** → GitOps, Helm, Operators

### Production Readiness
- Cloud provider integration (AWS EKS, GCP GKE)
- Production cluster setup and management
- Advanced networking (Ingress, CNI plugins)
- Backup and disaster recovery

---

**🧪 Ready to Start?** Head to `lab/lab1/` to begin your hands-on Kubernetes journey!

**💡 Learning Tip**: These labs are designed to be completed multiple times. Each iteration will deepen your understanding and build muscle memory for common operations.
