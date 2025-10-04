# Lab 2: Create & Manage Pods - Basic Pod Operations

Welcome to Lab 2! This lab focuses on hands-on Pod creation, management, and basic Kubernetes operations. You'll learn to create Pods manually, manage them with Deployments, and expose them using Services.

## 🎯 Lab Objectives

By the end of this lab, you will:
- ✅ Create and manage individual Pods using YAML manifests
- ✅ Understand Pod-to-Node mapping and scheduling
- ✅ Access Pod logs and execute commands inside containers
- ✅ Work with namespaces and Pod organization
- ✅ Expose Pods using Services for network access
- ✅ Use Deployments for automated Pod management
- ✅ Compare manual Pod creation vs Deployment management

## ⏱️ Estimated Duration: 1-1.5 hours

## 📋 Prerequisites

### Required Completion
- ✅ **Lab 1 completed** → Environment setup and basic operations
- ✅ **Active Kind cluster** → Your cluster from Lab 1 should be running
- ✅ **Core concepts understood** → Pods, Services, Namespaces, Labels

### Verification Commands
```bash
# Verify your cluster is ready
kubectl cluster-info
kubectl get nodes

# Check if you have a working cluster from Lab 1
kind get clusters
```

---

## 🚀 Lab Structure

```
lab2/
├── manifests/        # Pre-built YAML configurations
├── exercises/        # Step-by-step practical exercises  
├── solutions/        # Complete solutions and examples
└── README.md         # This comprehensive guide
```

---

## 📍 Phase 1: Understanding Deployments (25-30 minutes)

## 🧠 What You'll Learn

**Core Pod Concepts:**
- Manual Pod creation and lifecycle
- Pod-to-Node mapping and scheduling
- Pod logs and troubleshooting
- Difference between Pods and Deployments

**Hands-on Skills:**
- Creating Pods from YAML manifests
- Inspecting Pod details and status
- Exposing Pods through Services
- Understanding Pod limitations vs Deployments

---

## 📍 Phase 1: Understanding Pods (20 minutes)

### What is a Pod?

A **Pod** is the smallest deployable unit in Kubernetes. Key characteristics:

- **Single or Multiple Containers**: Usually one container, but can contain multiple tightly coupled containers
- **Shared Resources**: Containers in a Pod share storage, network (IP), and lifecycle
- **Ephemeral**: Pods are temporary - they can be created, destroyed, and recreated
- **Manual Management**: Unlike Deployments, Pods require manual lifecycle management

### Exercise 1: Create Your First Pod

**Step 1: Create Lab Directory**

```bash
# Create lab2 workspace
mkdir -p ~/k8s-lab2
cd ~/k8s-lab2

# Verify kubectl connection
kubectl cluster-info
kubectl get nodes
```

**Step 2: Create Apache Pod YAML**

```bash
# Create apache1.yaml
cat > apache1.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: apache1
  labels:
    app: apache
    tier: web
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

# Deploy the Pod
kubectl apply -f apache1.yaml

# Check Pod creation
kubectl get pods
kubectl get pods -o wide
```

**Expected Output:**
```
NAME      READY   STATUS    RESTARTS   AGE   IP           NODE
apache1   1/1     Running   0          30s   10.244.0.5   kind-control-plane
```

### Exercise 2: Pod Inspection and Management

**Step 1: Detailed Pod Information**

```bash
# Get detailed Pod information
kubectl describe pod apache1

# Check Pod logs
kubectl logs apache1

# Get Pod YAML configuration
kubectl get pod apache1 -o yaml

# Check which Node the Pod is running on
kubectl get pod apache1 -o wide
```

**Step 2: Interactive Pod Access**

```bash
# Execute commands inside the Pod
kubectl exec -it apache1 -- /bin/bash

# Once inside the container, try these commands:
# whoami
# ps aux
# cat /etc/hostname
# exit

# Execute single command without interactive mode
kubectl exec apache1 -- ps aux
kubectl exec apache1 -- ls -la /usr/local/apache2/htdocs/
```

### Exercise 3: Create Second Apache Pod

**Step 1: Create Another Pod**

```bash
# Create apache2.yaml
cat > apache2.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: apache2
  labels:
    app: apache
    tier: web
    version: v2
spec:
  containers:
  - name: apache-container
    image: httpd:2.4
    ports:
    - containerPort: 80
    env:
    - name: SERVER_NAME
      value: "apache2-server"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF

# Deploy the second Pod
kubectl apply -f apache2.yaml

# List all Pods with labels
kubectl get pods --show-labels
kubectl get pods -l app=apache
```

**Step 2: Compare Pod Details**

```bash
# Compare both Pods
kubectl get pods -o wide

# Check both Pods' environments
kubectl exec apache1 -- printenv | grep SERVER
kubectl exec apache2 -- printenv | grep SERVER

# View Pod events
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

## 📍 Phase 2: Pod Networking and Services (25 minutes)

### Exercise 4: Pod-to-Pod Communication

**Step 1: Test Direct Pod Communication**

```bash
# Get Pod IPs
kubectl get pods -o wide

# Test connectivity from apache1 to apache2 (use actual IP)
kubectl exec apache1 -- curl -s http://10.244.0.6:80
# (Replace 10.244.0.6 with actual apache2 IP)

# Test from apache2 to apache1
kubectl exec apache2 -- curl -s http://10.244.0.5:80
# (Replace 10.244.0.5 with actual apache1 IP)
```

**Problem**: Direct Pod IP communication is unreliable because Pod IPs change when Pods restart!

### Exercise 5: Create Service for Pod Access

**Step 1: Create Service YAML**

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

# Deploy the Service
kubectl apply -f apache-service.yaml

# Verify Service creation
kubectl get services
kubectl get service apache-service
kubectl describe service apache-service
```

**Step 2: Test Service Connectivity**

```bash
# Check Service endpoints
kubectl get endpoints apache-service

# Create a test Pod for connectivity testing
cat > test-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: curlimages/curl
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
EOF

# Deploy test Pod
kubectl apply -f test-pod.yaml
kubectl wait --for=condition=ready pod/test-pod

# Test Service connectivity
kubectl exec test-pod -- curl -s http://apache-service:80
kubectl exec test-pod -- nslookup apache-service
```

### Exercise 6: External Access via NodePort

**Step 1: Create NodePort Service**

```bash
# Create external access service
cat > apache-nodeport.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: apache-external
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

# Deploy NodePort Service
kubectl apply -f apache-nodeport.yaml

# Check Services
kubectl get services
```

**Step 2: Test External Access**

```bash
# Port forward for testing (Kind limitation workaround)
kubectl port-forward service/apache-external 8080:80 &

# Test access (open new terminal window)
curl http://localhost:8080

# Stop port forward
pkill -f "kubectl port-forward"
```

---

## 📍 Phase 3: Pod vs Deployment Comparison (20 minutes)

### Exercise 7: Understanding Pod Limitations

**Step 1: Simulate Pod Failure**

```bash
# Delete one Pod manually
kubectl delete pod apache1

# Check remaining Pods
kubectl get pods

# Try to access Service now
kubectl exec test-pod -- curl -s http://apache-service:80

# Notice: apache1 is gone forever! No automatic replacement
```

**Step 2: Create Deployment for Comparison**

```bash
# Create apache-deployment.yaml
cat > apache-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
  labels:
    app: apache-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: apache-deploy
  template:
    metadata:
      labels:
        app: apache-deploy
        tier: web
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

# Deploy the Deployment
kubectl apply -f apache-deployment.yaml

# Check created resources
kubectl get deployments
kubectl get replicasets
kubectl get pods -l app=apache-deploy
```

**Step 3: Test Deployment Self-Healing**

```bash
# Delete a Deployment-managed Pod
kubectl get pods -l app=apache-deploy
kubectl delete pod <pod-name-from-deployment>

# Watch automatic replacement
kubectl get pods -l app=apache-deploy -w
# (Ctrl+C to stop watching)

# Notice: Deployment automatically creates a new Pod!
```

### Exercise 8: Comparison Summary

**Step 1: Resource Overview**

```bash
# List all resources
kubectl get all

# Compare Pod vs Deployment management:
echo "=== Manual Pods ==="
kubectl get pods -l app=apache

echo "=== Deployment-managed Pods ==="
kubectl get pods -l app=apache-deploy
kubectl get deployment apache-deployment
```

**Key Differences:**

| Aspect | Pod | Deployment |
|--------|-----|------------|
| **Creation** | Manual YAML | Automatic via template |
| **Scaling** | Create/Delete manually | `kubectl scale` |
| **Updates** | Replace manually | Rolling updates |
| **Self-healing** | None | Automatic replacement |
| **Rollback** | Not supported | Built-in rollback |
| **Use Case** | Testing, debugging | Production workloads |

---

## 📍 Phase 4: Advanced Pod Operations (15 minutes)

### Exercise 9: Pod Troubleshooting

**Step 1: Create Problematic Pod**

```bash
# Create a Pod with issues
cat > problem-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: problem-pod
spec:
  containers:
  - name: broken-container
    image: nginx:nonexistent-tag
    ports:
    - containerPort: 80
EOF

# Deploy problematic Pod
kubectl apply -f problem-pod.yaml

# Check Pod status
kubectl get pods
kubectl describe pod problem-pod
```

**Step 2: Troubleshooting Steps**

```bash
# 1. Check Pod events
kubectl describe pod problem-pod

# 2. Check Pod logs (if container started)
kubectl logs problem-pod

# 3. Check Node resources
kubectl describe node

# Fix the Pod by updating image
kubectl patch pod problem-pod -p='{"spec":{"containers":[{"name":"broken-container","image":"nginx:latest"}]}}'

# Note: Pods are immutable for most fields, so this might fail
# Better approach: Delete and recreate
kubectl delete pod problem-pod

# Create fixed version
cat > fixed-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: fixed-pod
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
EOF

kubectl apply -f fixed-pod.yaml
kubectl get pods
```

### Exercise 10: Pod Resource Management

**Step 1: Monitor Pod Resources**

```bash
# Check Pod resource usage (if metrics-server available)
kubectl top pods

# Describe Pod resources
kubectl describe pod apache2
kubectl describe pod fixed-pod

# Get Pod resource requests and limits
kubectl get pod apache2 -o jsonpath='{.spec.containers[0].resources}'
```

**Step 2: Pod Quality of Service**

```bash
# Check QoS classes
kubectl get pods -o custom-columns="NAME:.metadata.name,QOS:.status.qosClass"

# Explain QoS classes:
# - Guaranteed: requests == limits for all resources
# - Burstable: has requests/limits but not equal
# - BestEffort: no requests or limits
```

---

## 📍 Phase 5: Cleanup and Review (10 minutes)

### Step 1: Comprehensive Cleanup

```bash
# List all created resources
kubectl get all

# Delete Pods
kubectl delete pod apache2 test-pod fixed-pod

# Delete Services
kubectl delete service apache-service apache-external

# Delete Deployment
kubectl delete deployment apache-deployment

# Verify cleanup
kubectl get all
```

### Step 2: Summary Commands

```bash
# Verify cluster is clean
kubectl get pods
kubectl get services
kubectl get deployments

# Check cluster status
kubectl get nodes
kubectl cluster-info
```

---

## 🎯 Lab Summary

### What You've Accomplished

✅ **Pod Fundamentals**
- Created Pods from YAML manifests
- Inspected Pod details and logs
- Executed commands inside Pods
- Understood Pod networking basics

✅ **Pod Management**
- Created multiple Pods with different configurations
- Tested Pod-to-Pod communication
- Managed Pod lifecycle manually

✅ **Services and Networking**
- Created ClusterIP Services for internal access
- Set up NodePort Services for external access
- Understood Service discovery and DNS

✅ **Pod vs Deployment**
- Compared manual Pod management with Deployments
- Witnessed self-healing capabilities of Deployments
- Learned when to use Pods vs Deployments

✅ **Troubleshooting**
- Diagnosed Pod creation issues
- Fixed configuration problems
- Monitored Pod resources and status

### Key Concepts Mastered

**Pod Characteristics:**
- Smallest deployable unit in Kubernetes
- Ephemeral and manually managed
- Share network and storage within Pod
- Direct IP-to-IP communication possible but unreliable

**Pod Limitations:**
- No automatic replacement when deleted
- Manual scaling required
- No built-in update strategy
- No rollback capabilities

**When to Use Pods Directly:**
- Development and testing
- Debugging applications
- One-time jobs or tasks
- Learning Kubernetes concepts

**When to Use Deployments:**
- Production workloads
- Applications requiring high availability
- Services that need scaling
- Applications requiring rolling updates

---

## 🚀 Next Steps

### Advanced Pod Topics
1. **Multi-container Pods** → Sidecar patterns
2. **Init Containers** → Initialization logic
3. **Pod Security** → SecurityContext and policies
4. **Pod Networking** → CNI and network policies
5. **Pod Storage** → Volumes and persistent storage

### Production Best Practices
- Always use Deployments for production workloads
- Set resource requests and limits on all containers
- Implement health checks (covered in advanced labs)
- Use meaningful labels and selectors
- Follow naming conventions

### Troubleshooting Skills
- Use `kubectl describe` for detailed information
- Check `kubectl logs` for container output
- Monitor `kubectl get events` for cluster events
- Use `kubectl exec` for interactive debugging

---

## 📚 Additional Resources

### Documentation
- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)

### Best Practices
- Pods should be stateless when possible
- Use proper resource requests and limits
- Implement health checks for production Pods
- Use Deployments instead of bare Pods for production
- Follow the single responsibility principle for containers

---

**🎉 Congratulations!** You've mastered the fundamentals of Pod operations in Kubernetes! You now understand the building blocks of Kubernetes applications and when to use Pods directly vs. higher-level abstractions like Deployments.

**💡 Pro Tip**: While Pods are rarely used directly in production, understanding them deeply is crucial for troubleshooting and advanced Kubernetes operations. Practice these concepts regularly to build muscle memory!
