# Kubernetes Labs - Hands-on Practice Hub

This directory contains comprehensive hands-on laboratories designed to transform theoretical knowledge into practical skills.

## 🧪 Available Labs

### Sequential Learning Path
Complete these labs in order for the best learning experience:

| Lab | Focus Area | Duration | Difficulty |
|-----|------------|----------|------------|
| **[Lab 1](./lab1/)** | Environment Setup & Basic Operations | 1-1.5 hours | Beginner |
| **[Lab 2](./lab2/)** | Advanced Deployments & Services | 1.5-2 hours | Intermediate |

## 📚 Lab Structure

Each lab follows a consistent structure:

```
labX/
├── README.md          # Complete lab guide and instructions
├── setup/            # Installation scripts and configurations
├── exercises/        # Step-by-step practical exercises
├── manifests/        # YAML configuration files
├── solutions/        # Complete solutions and examples
└── troubleshooting/  # Common issues and solutions
```

## 🎯 Learning Objectives

### Core Skills You'll Develop
- **Cluster Management** → Create, configure, and manage K8s clusters
- **Workload Deployment** → Deploy applications using Pods, Deployments
- **Service Configuration** → Expose and connect applications
- **Network Understanding** → Service discovery, DNS, load balancing
- **Troubleshooting** → Debug issues using kubectl and logs
- **Best Practices** → Production-ready configuration patterns

### Practical Outcomes
By completing these labs, you'll be able to:
- Set up development clusters locally
- Deploy applications from YAML manifests
- Scale applications based on demand
- Implement service discovery
- Debug common deployment issues
- Apply security and resource management

## 🛠️ Prerequisites

### Required Knowledge
- Basic Linux command line skills
- Understanding of containers (Docker basics)
- Completion of theoretical documentation in `../docs/`

### System Setup
```bash
# Verify your system meets requirements
echo "Checking system requirements..."
echo "OS: $(lsb_release -d)"
echo "RAM: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "CPU Cores: $(nproc)"
echo "Disk Space: $(df -h / | awk 'NR==2 {print $4}')"
```

### Tool Installation Status
Check if required tools are installed:
```bash
# Check Docker
docker --version 2>/dev/null && echo "✅ Docker installed" || echo "❌ Docker missing"

# Check kubectl
kubectl version --client 2>/dev/null && echo "✅ kubectl installed" || echo "❌ kubectl missing"

# Check Kind
kind version 2>/dev/null && echo "✅ Kind installed" || echo "❌ Kind missing"
```

## 🚀 Quick Start Guide

### 1. Choose Your Starting Point

**New to Kubernetes?**
→ Start with [Lab 1](./lab1/) after reading all documentation

**Have Some Experience?**
→ Review [Lab 1](./lab1/) setup, then proceed based on your comfort level

**Want to Test Knowledge?**
→ Try exercises without reading solutions first

### 2. Set Up Your Workspace

```bash
# Create a dedicated workspace
mkdir -p ~/k8s-learning
cd ~/k8s-learning

# Clone or copy lab files
cp -r /path/to/labs/ ./

# Start with Lab 1
cd lab1/
```

### 3. Follow the Learning Path

1. **Read** → Lab README and exercise descriptions
2. **Practice** → Complete exercises step by step
3. **Experiment** → Try variations and modifications
4. **Troubleshoot** → Fix issues when things don't work
5. **Review** → Compare your solutions with provided ones

## 📊 Progress Tracking

### Lab 1: Foundation Skills
- [ ] Environment setup completed
- [ ] First Pod created and running
- [ ] Service exposure working
- [ ] Basic kubectl commands mastered
- [ ] Namespace operations understood

### Lab 2: Intermediate Operations
- [ ] Deployments created and managed
- [ ] Scaling operations performed
- [ ] Rolling updates executed
- [ ] Resource management implemented
- [ ] Health checks configured

## 🔍 Troubleshooting Resources

### Common Setup Issues

#### Permission Problems
```bash
# Docker permission denied
sudo usermod -aG docker $USER
# Logout and login again

# kubectl access issues
kubectl config view
kubectl cluster-info
```

#### Resource Constraints
```bash
# Check available resources
docker system df        # Docker disk usage
docker system prune     # Clean up unused resources
kind delete cluster     # Remove old clusters
```

### Debug Commands Cheat Sheet
```bash
# Cluster health
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# Object investigation
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp

# Network debugging
kubectl get svc
kubectl get endpoints
```

## 🎯 Success Metrics

### Knowledge Validation
After each lab, you should be able to explain:
- What each Kubernetes object does
- How components interact
- Why specific configurations are needed
- How to troubleshoot common issues

### Practical Validation
Demonstrate these skills:
- Create clusters from scratch
- Deploy applications reliably
- Modify running deployments
- Diagnose and fix problems
- Apply best practices

## 🌟 Beyond the Labs

### Next Learning Steps
- **Storage**: Persistent volumes and claims
- **Configuration**: ConfigMaps and Secrets
- **Security**: RBAC and network policies
- **Monitoring**: Observability and alerting
- **Production**: Cloud provider integration

### Community Resources
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [CNCF Community](https://community.cncf.io/)
- [Local Kubernetes Meetups](https://www.meetup.com/topics/kubernetes/)

## 📝 Lab Feedback

### Continuous Improvement
These labs are designed to evolve. Consider:
- Which exercises were most helpful?
- Where did you encounter difficulties?
- What additional topics would be valuable?
- How could instructions be clearer?

### Self-Assessment Questions
- Can I explain Kubernetes concepts to others?
- Am I comfortable with kubectl operations?
- Do I understand how to debug issues?
- Can I create production-ready configurations?

---

**🎓 Ready to Begin?** Start your hands-on journey with [Lab 1: Environment Setup & Basic Operations](./lab1/)!

**💡 Learning Philosophy**: The goal isn't to memorize commands, but to understand patterns and develop problem-solving skills that will serve you in real-world scenarios.
