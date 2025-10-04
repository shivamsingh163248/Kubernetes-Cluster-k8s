# Lab 1: Environment Setup & Basic Kubernetes Operations

Welcome to your first hands-on Kubernetes lab! This lab will guide you through setting up a local Kubernetes cluster and performing fundamental operations.

## 🎯 Lab Objectives

By the end of this lab, you will:
- ✅ Set up a local Kubernetes cluster using Kind
- ✅ Understand cluster components and verify their status
- ✅ Create and manage Pods using YAML manifests
- ✅ Work with Namespaces and Labels
- ✅ Expose applications using Services
- ✅ Master essential kubectl commands
- ✅ Troubleshoot common issues

## ⏱️ Estimated Duration: 1-1.5 hours

## 📋 Prerequisites

### Knowledge Requirements
- Completed reading of `../../../docs/` section
- Basic Linux command line skills
- Understanding of YAML syntax

### System Requirements
- Ubuntu 20.04+ or Debian 10+
- 4GB RAM (8GB recommended)
- 20GB free disk space
- Internet connectivity

### Required Tools
We'll install these during the lab:
- Docker (container runtime)
- kubectl (Kubernetes CLI)
- Kind (local Kubernetes clusters)

## 🚀 Lab Structure

```
lab1/
├── setup/            # Installation scripts and verification
├── exercises/        # Step-by-step practical exercises
├── solutions/        # Complete solutions and examples
└── README.md         # This file
```

---

## 📍 Phase 1: Environment Setup (20-30 minutes)

### Step 1: System Preparation

First, let's prepare your system and install required tools.

```bash
# Update system packages
sudo apt update -y
sudo apt install -y curl apt-transport-https ca-certificates conntrack

# Verify system resources
echo "System Information:"
echo "==================="
echo "OS: $(lsb_release -d | cut -f2)"
echo "RAM: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "CPU Cores: $(nproc)"
echo "Disk Space: $(df -h / | awk 'NR==2 {print $4}' | sed 's/G/ GB/')"
```

### Step 2: Install Docker

```bash
# Install Docker
sudo apt install -y docker.io

# Start and enable Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add your user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Verify Docker installation
docker --version

# Note: You may need to log out and back in for group changes to take effect
echo "Please log out and log back in if you get permission errors with Docker"
```

### Step 3: Install kubectl

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable and move to PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Step 4: Install Kind

```bash
# Download Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64

# Make it executable and move to PATH  
chmod +x kind
sudo mv kind /usr/local/bin/

# Verify installation
kind version
```

### Step 5: Create Your First Kubernetes Cluster

```bash
# Create a Kind cluster
echo "Creating Kubernetes cluster..."
kind create cluster --name mycluster

# This will:
# 1. Pull the Kubernetes node image
# 2. Create a Docker container acting as a K8s node
# 3. Install Kubernetes components
# 4. Configure kubectl to connect to the cluster

# Verify cluster creation
echo "Verifying cluster..."
kubectl cluster-info
kubectl get nodes
```

**Expected Output:**
```
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   1m    v1.29.0
```

### Step 6: Verify Cluster Components

```bash
# Check all system pods
kubectl get pods --all-namespaces

# Check system namespaces
kubectl get namespaces

# View cluster information
kubectl cluster-info
```

**Understanding the Output:**
- `kube-system` namespace contains cluster components
- Control plane components are running as pods
- The node shows as "Ready" status

---

## 📍 Phase 2: Basic Pod Operations (20-30 minutes)

### Exercise 1: Create Your First Pod

Let's create a simple Apache web server pod.

**Step 1: Create Pod YAML**

Navigate to the exercises directory and create your first pod:

```bash
# Create a working directory
mkdir -p ~/k8s-lab1
cd ~/k8s-lab1

# Create apache-pod.yaml
cat > apache-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: apache-pod
  labels:
    app: apache
    environment: lab
spec:
  containers:
  - name: apache-container
    image: httpd:latest
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF
```

**Step 2: Deploy the Pod**

```bash
# Apply the configuration
kubectl apply -f apache-pod.yaml

# Verify pod creation
kubectl get pods

# Watch pod status (Ctrl+C to exit)
kubectl get pods -w
```

**Step 3: Inspect the Pod**

```bash
# Get detailed pod information
kubectl describe pod apache-pod

# View pod logs
kubectl logs apache-pod

# Get pod in YAML format
kubectl get pod apache-pod -o yaml
```

### Exercise 2: Working with Namespaces

**Step 1: Create a Development Namespace**

```bash
# Create namespace
kubectl create namespace development

# List all namespaces
kubectl get namespaces

# Deploy pod to development namespace
kubectl apply -f apache-pod.yaml -n development

# List pods in development namespace
kubectl get pods -n development
```

**Step 2: Understanding Namespace Isolation**

```bash
# Pods in default namespace
kubectl get pods

# Pods in development namespace
kubectl get pods -n development

# All pods across namespaces
kubectl get pods --all-namespaces
```

### Exercise 3: Labels and Selectors

**Step 1: Working with Labels**

```bash
# Show pod labels
kubectl get pods --show-labels

# Filter pods by label
kubectl get pods -l app=apache
kubectl get pods -l environment=lab

# Add a new label
kubectl label pod apache-pod tier=frontend

# View updated labels
kubectl get pods --show-labels
```

**Step 2: Create Multiple Pods with Different Labels**

```bash
# Create nginx-pod.yaml
cat > nginx-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: lab
    tier: frontend
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
EOF

# Deploy nginx pod
kubectl apply -f nginx-pod.yaml

# View all pods with labels
kubectl get pods --show-labels

# Filter by different labels
kubectl get pods -l tier=frontend
kubectl get pods -l environment=lab
```

---

## 📍 Phase 3: Service Creation and Networking (20-30 minutes)

### Exercise 4: Expose Pods with Services

**Step 1: Create a ClusterIP Service**

```bash
# Create apache-service.yaml
cat > apache-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: apache-service
  labels:
    app: apache
spec:
  selector:
    app: apache
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Deploy the service
kubectl apply -f apache-service.yaml

# Verify service creation
kubectl get services
kubectl describe service apache-service
```

**Step 2: Test Service Connectivity**

```bash
# Check service endpoints
kubectl get endpoints apache-service

# Create a test pod for networking
cat > test-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    stdin: true
    tty: true
EOF

# Deploy test pod
kubectl apply -f test-pod.yaml

# Wait for pod to be ready
kubectl wait --for=condition=ready pod/test-pod

# Test service connectivity
kubectl exec -it test-pod -- curl http://apache-service:80
kubectl exec -it test-pod -- nslookup apache-service
```

### Exercise 5: NodePort Service

**Step 1: Create NodePort Service**

```bash
# Create apache-nodeport.yaml
cat > apache-nodeport.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: apache-nodeport
spec:
  selector:
    app: apache
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

# Deploy NodePort service
kubectl apply -f apache-nodeport.yaml

# View services
kubectl get services
```

**Step 2: Test External Access**

```bash
# Get node information
kubectl get nodes -o wide

# Test access (Kind uses Docker, so we use port-forward)
kubectl port-forward service/apache-nodeport 8080:80 &

# Test in another terminal
curl http://localhost:8080

# Stop port-forward
pkill -f "kubectl port-forward"
```

---

## 📍 Phase 4: Advanced Operations & Troubleshooting (15-20 minutes)

### Exercise 6: Pod Lifecycle Management

**Step 1: Update and Recreate Pods**

```bash
# Delete and recreate apache pod
kubectl delete pod apache-pod

# Verify deletion
kubectl get pods

# Recreate from YAML
kubectl apply -f apache-pod.yaml

# Watch pod startup
kubectl get pods -w
```

**Step 2: Resource Management**

```bash
# Check resource usage
kubectl top nodes
kubectl top pods

# View pod resource specifications
kubectl describe pod apache-pod | grep -A 10 "Requests\|Limits"
```

### Exercise 7: Troubleshooting Common Issues

**Step 1: Simulate Pod Failure**

```bash
# Create a failing pod
cat > failing-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: failing-pod
spec:
  containers:
  - name: failing-container
    image: nonexistent-image:latest
    command: ["echo", "This will fail"]
EOF

# Apply failing configuration
kubectl apply -f failing-pod.yaml

# Observe the failure
kubectl get pods
kubectl describe pod failing-pod
```

**Step 2: Debug and Fix**

```bash
# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Fix the pod by using correct image
cat > fixed-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: fixed-pod
spec:
  containers:
  - name: working-container
    image: nginx:latest
    ports:
    - containerPort: 80
EOF

# Deploy fixed pod
kubectl apply -f fixed-pod.yaml
kubectl get pods
```

---

## 📍 Phase 5: Cleanup and Review (10 minutes)

### Step 1: Clean Up Resources

```bash
# Delete all created pods
kubectl delete pod apache-pod nginx-pod test-pod failing-pod fixed-pod

# Delete pods in development namespace
kubectl delete pod apache-pod -n development

# Delete services
kubectl delete service apache-service apache-nodeport

# Delete namespace
kubectl delete namespace development

# Verify cleanup
kubectl get pods
kubectl get services
kubectl get namespaces
```

### Step 2: Cluster Management

```bash
# View cluster information one more time
kubectl cluster-info
kubectl get nodes

# Optional: Delete the cluster (if you want to start fresh)
# kind delete cluster --name mycluster

# List all Kind clusters
kind get clusters
```

---

## 🎯 Lab Summary

### What You've Accomplished

✅ **Environment Setup**
- Installed Docker, kubectl, and Kind
- Created a local Kubernetes cluster
- Verified all components are working

✅ **Pod Management**
- Created pods using YAML manifests
- Used labels for organization
- Managed pod lifecycle

✅ **Namespace Operations**
- Created and used custom namespaces
- Deployed resources to specific namespaces
- Understood namespace isolation

✅ **Service Networking**
- Created ClusterIP and NodePort services
- Tested internal and external connectivity
- Used DNS for service discovery

✅ **Troubleshooting**
- Debugged failed pod deployments
- Used kubectl describe and logs
- Understood common error patterns

### Key Commands You've Learned

```bash
# Cluster management
kind create cluster --name mycluster
kubectl cluster-info
kubectl get nodes

# Object management  
kubectl apply -f <file>
kubectl get pods/services/namespaces
kubectl describe <resource> <name>
kubectl delete <resource> <name>

# Namespace operations
kubectl create namespace <name>
kubectl get pods -n <namespace>

# Debugging
kubectl logs <pod-name>
kubectl describe pod <pod-name>
kubectl get events
```

---

## 🚀 Next Steps

### Immediate Actions
1. **Review** → Go through the solutions directory
2. **Experiment** → Try modifying YAML files and see what happens
3. **Practice** → Recreate the lab without looking at instructions

### Prepare for Lab 2
- Ensure your cluster is running
- Review Deployment concepts in documentation
- Be ready for more advanced scenarios

### Additional Learning
- Explore kubectl help: `kubectl help`
- Read about other resource types: `kubectl api-resources`
- Practice with different container images

---

## 🔍 Troubleshooting Guide

### Common Issues and Solutions

#### Docker Permission Denied
```bash
# Add user to docker group and restart session
sudo usermod -aG docker $USER
# Log out and log back in
```

#### Kind Cluster Won't Start
```bash
# Check Docker is running
sudo systemctl status docker

# Clean up and recreate
kind delete cluster --name mycluster
kind create cluster --name mycluster
```

#### kubectl Connection Issues
```bash
# Verify cluster context
kubectl config current-context

# Check cluster status
kubectl cluster-info
kubectl get nodes
```

#### Pod Won't Start
```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

**🎉 Congratulations!** You've successfully completed Lab 1. You now have a solid foundation in basic Kubernetes operations and are ready to move on to more advanced concepts in Lab 2.

**💡 Pro Tip**: Keep your cluster running and experiment with different configurations. The best learning happens when you break things and figure out how to fix them!
