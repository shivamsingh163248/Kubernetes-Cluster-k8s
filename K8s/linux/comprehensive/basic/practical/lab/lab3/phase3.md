# 📘 Phase 3: Kubernetes – Namespaces, Labels & Updates

This phase builds on Pods/Services/Deployments from Phase 2 and adds logical separation (Namespaces), filtering (Labels/Selectors), and updates (Rolling Updates & Rollbacks).

## 🎯 Learning Objectives

By the end of Phase 3, you will:
- ✅ **Master Namespaces** → Logical isolation for different environments
- ✅ **Use Labels & Selectors** → Organize and filter Kubernetes resources
- ✅ **Perform Rolling Updates** → Update applications without downtime
- ✅ **Handle Rollbacks** → Safely revert to previous versions
- ✅ **Scale Deployments** → Adjust application capacity dynamically

## ⏱️ Estimated Duration: 45-60 minutes

## 📋 Prerequisites

### Required Completion
- ✅ **Phase 1 & 2 completed** → Cluster setup and basic Pod/Service operations
- ✅ **Active Kubernetes cluster** → Kind/Minikube cluster running
- ✅ **kubectl configured** → CLI access to cluster

### Verification Commands
```bash
# Verify your environment is ready
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

---

## 🔹 Lab 1 – Namespaces

### Step 1: View all namespaces

```bash
kubectl get ns
```

✅ **Output:**

```
NAME              STATUS   AGE
default           Active   2h
kube-system       Active   2h
kube-public       Active   2h
kube-node-lease   Active   2h
```

### Step 2: Create a new namespace

```bash
kubectl create namespace dev
kubectl create namespace prod
```

**Check:**

```bash
kubectl get ns
```

✅ **Output:**

```
NAME              STATUS   AGE
default           Active   2h
dev               Active   5s
prod              Active   5s
kube-system       Active   2h
kube-public       Active   2h
kube-node-lease   Active   2h
```

### Step 3: Deploy Pods in a namespace

**apache-dev.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache-dev
  namespace: dev
  labels:
    app: apache
spec:
  containers:
  - name: apache
    image: httpd
    ports:
    - containerPort: 80
```

**Apply:**

```bash
kubectl apply -f apache-dev.yaml
```

**Check:**

```bash
kubectl get pods -n dev
```

✅ **Output:**

```
NAME         READY   STATUS    RESTARTS   AGE
apache-dev   1/1     Running   0          5s
```

**Verify namespace isolation:**

```bash
# Check default namespace - should be empty or show different pods
kubectl get pods

# Check dev namespace - shows apache-dev
kubectl get pods -n dev

# Check all namespaces
kubectl get pods --all-namespaces
```

---

## 🔹 Lab 2 – Labels & Selectors

### Step 1: View Pod labels

```bash
kubectl get pods --show-labels
```

✅ **Example Output:**

```
NAME         READY   STATUS    RESTARTS   AGE   LABELS
apache-dev   1/1     Running   0          5m    app=apache
```

### Step 2: Add a new label

```bash
kubectl label pod apache-dev env=dev -n dev
```

**Check:**

```bash
kubectl get pods -n dev --show-labels
```

✅ **Output:**

```
NAME         READY   STATUS    RESTARTS   AGE   LABELS
apache-dev   1/1     Running   0          7m    app=apache,env=dev
```

### Step 3: Select Pods by label

```bash
kubectl get pods -n dev -l app=apache
kubectl get pods -n dev -l env=dev
```

👉 **Only Pods with matching labels are listed.**

**Advanced label operations:**

```bash
# Multiple label selection
kubectl get pods -n dev -l "app=apache,env=dev"

# Label not equal
kubectl get pods -n dev -l "app!=nginx"

# Check if label exists
kubectl get pods -n dev -l env

# Remove a label
kubectl label pod apache-dev env- -n dev
```

**Create more Pods for testing:**

```bash
# Create apache-prod.yaml
cat > apache-prod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: apache-prod
  namespace: prod
  labels:
    app: apache
    env: prod
    tier: web
spec:
  containers:
  - name: apache
    image: httpd
    ports:
    - containerPort: 80
EOF

# Apply it
kubectl apply -f apache-prod.yaml

# Test cross-namespace label selection
kubectl get pods -l app=apache --all-namespaces
```

✅ **Output shows Pods with app=apache from all namespaces:**

```
NAMESPACE   NAME         READY   STATUS    RESTARTS   AGE
dev         apache-dev   1/1     Running   0          10m
prod        apache-prod  1/1     Running   0          2m
```

---

## 🔹 Lab 3 – Rolling Updates with Deployment

### Step 1: Create Deployment v1

**nginx-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.19   # old version
        ports:
        - containerPort: 80
```

**Apply:**

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods -l app=nginx
```

**Expected Output:**

```bash
kubectl get deploy
```

✅ **Output:**

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           30s
```

**Check initial Pods:**

```bash
kubectl get pods -l app=nginx -o wide
```

✅ **Output:**

```
NAME                               READY   STATUS    RESTARTS   AGE   IP           NODE
nginx-deployment-7d4c8b5f9b-k8n2m  1/1     Running   0          45s   10.244.0.15  kind-control-plane
nginx-deployment-7d4c8b5f9b-x7p4q  1/1     Running   0          45s   10.244.0.16  kind-control-plane
```

### Step 2: Update Deployment (Rolling Update)

**Change image to a newer version:**

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.21
```

**Check rollout:**

```bash
kubectl rollout status deployment/nginx-deployment
```

✅ **Output:**

```
deployment "nginx-deployment" successfully rolled out
```

**Monitor the rolling update process:**

```bash
# Watch Pods during update
kubectl get pods -l app=nginx -w
# (Press Ctrl+C to stop watching)

# Check rollout history
kubectl rollout history deployment/nginx-deployment
```

### Step 3: Verify new Pods

```bash
kubectl get pods -l app=nginx -o wide
```

👉 **You'll see old Pods terminated, new Pods running with nginx:1.21.**

**Verify image version:**

```bash
kubectl describe deployment nginx-deployment | grep Image
```

✅ **Output:**

```
    Image:        nginx:1.21
```

### Step 4: Rollback Deployment

```bash
kubectl rollout undo deployment/nginx-deployment
```

**Check again:**

```bash
kubectl get pods -l app=nginx -o wide
```

✅ **Back to nginx:1.19.**

**Verify rollback:**

```bash
kubectl describe deployment nginx-deployment | grep Image
kubectl rollout history deployment/nginx-deployment
```

**Advanced rollback operations:**

```bash
# Rollback to specific revision
kubectl rollout history deployment/nginx-deployment --revision=1
kubectl rollout undo deployment/nginx-deployment --to-revision=1

# Check rollout status
kubectl rollout status deployment/nginx-deployment
```

---

## 🔹 Lab 4 – Scaling Deployments (Quick Review)

### Scale up:

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

**Verify scaling:**

```bash
kubectl get deployment nginx-deployment
kubectl get pods -l app=nginx
```

✅ **Expected output shows 5 pods:**

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   5/5     5            5           10m
```

### Scale down:

```bash
kubectl scale deployment nginx-deployment --replicas=2
```

**Advanced scaling operations:**

```bash
# Auto-scaling based on CPU (requires metrics-server)
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=1 --max=10

# Check horizontal pod autoscaler
kubectl get hpa
```

---

## 🔹 Lab 5 – Namespace Management & Resource Isolation

### Step 1: Create Resources in Different Namespaces

**Create identical deployments in different namespaces:**

```bash
# Deploy nginx in dev namespace
kubectl apply -f nginx-deployment.yaml -n dev

# Deploy nginx in prod namespace  
kubectl apply -f nginx-deployment.yaml -n prod
```

### Step 2: Compare Resources Across Namespaces

```bash
# View deployments in all namespaces
kubectl get deploy --all-namespaces

# View specific namespace deployments
kubectl get deploy -n dev
kubectl get deploy -n prod

# Compare pod counts
kubectl get pods -n dev -l app=nginx
kubectl get pods -n prod -l app=nginx
```

### Step 3: Namespace Resource Quotas (Advanced)

```bash
# Create resource quota for dev namespace
cat > dev-quota.yaml << 'EOF'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "10"
EOF

# Apply quota
kubectl apply -f dev-quota.yaml

# Check quota usage
kubectl describe quota dev-quota -n dev
```

---

## 🔹 Lab 6 – Advanced Label & Selector Operations

### Step 1: Complex Label Scenarios

```bash
# Create pods with multiple labels
cat > multi-label-pods.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: web-frontend
  namespace: dev
  labels:
    app: web
    tier: frontend
    version: v1
    environment: dev
spec:
  containers:
  - name: web
    image: nginx:1.21
---
apiVersion: v1
kind: Pod
metadata:
  name: web-backend
  namespace: dev
  labels:
    app: web
    tier: backend
    version: v1
    environment: dev
spec:
  containers:
  - name: web
    image: nginx:1.21
EOF

kubectl apply -f multi-label-pods.yaml
```

### Step 2: Advanced Label Selections

```bash
# Select by multiple labels
kubectl get pods -n dev -l "app=web,tier=frontend"

# Select by label values in set
kubectl get pods -n dev -l "tier in (frontend,backend)"

# Select by label existence
kubectl get pods -n dev -l version

# Select with NOT operations
kubectl get pods -n dev -l "tier notin (database,cache)"
```

---

## ✅ Phase 3 Summary

| Concept | Purpose | Key Commands |
|---------|---------|--------------|
| **Namespaces** | Logical isolation (dev, prod, test) | `kubectl create namespace`, `kubectl get ns` |
| **Labels/Selectors** | Organize and filter resources | `kubectl label`, `kubectl get -l` |
| **Deployments** | Handle updates safely with rollout/rollback | `kubectl rollout`, `kubectl set image` |
| **Scaling** | Increase/decrease replicas easily | `kubectl scale`, `kubectl autoscale` |

### **What You've Mastered:**

✅ **Namespace Operations:**
- Creating and managing namespaces
- Deploying resources to specific namespaces
- Cross-namespace resource viewing
- Resource isolation and quotas

✅ **Label Management:**
- Adding, removing, and modifying labels
- Complex label selectors
- Cross-namespace label filtering
- Multi-dimensional resource organization

✅ **Deployment Updates:**
- Rolling updates with zero downtime
- Rollback capabilities
- Update history tracking
- Image version management

✅ **Scaling Operations:**
- Manual scaling up/down
- Understanding replica management
- Auto-scaling concepts

---

## 🚀 Next Steps

### **Advanced Topics to Explore:**
1. **ConfigMaps & Secrets** → Application configuration management
2. **Persistent Volumes** → Data storage and persistence
3. **Ingress Controllers** → HTTP/HTTPS routing and load balancing
4. **Network Policies** → Pod-to-Pod communication security
5. **RBAC** → Role-based access control
6. **Monitoring & Logging** → Observability and troubleshooting

### **Production Best Practices:**
- Use namespaces to separate environments (dev, staging, prod)
- Implement resource quotas to prevent resource exhaustion
- Use meaningful labels for organization and automation
- Always test updates in non-production environments first
- Monitor rollout status and be ready to rollback if needed

---

## 🛠️ Troubleshooting Guide

### **Common Issues & Solutions:**

#### **Namespace Issues:**
```bash
# Pod not found - wrong namespace
kubectl get pods -n <namespace-name>

# List all resources in namespace
kubectl get all -n <namespace-name>

# Delete namespace (careful - deletes all resources!)
kubectl delete namespace <namespace-name>
```

#### **Label Selector Issues:**
```bash
# Check pod labels
kubectl describe pod <pod-name> -n <namespace>

# Verify selector syntax
kubectl get pods -l "app=nginx" --dry-run=client

# Test complex selectors
kubectl get pods -l "app in (nginx,apache),tier notin (database)"
```

#### **Rolling Update Issues:**
```bash
# Check rollout status
kubectl rollout status deployment/<deployment-name>

# View rollout history
kubectl rollout history deployment/<deployment-name>

# Pause/resume rollouts
kubectl rollout pause deployment/<deployment-name>
kubectl rollout resume deployment/<deployment-name>
```

---

**🎉 Congratulations!** You've successfully completed Phase 3 and now have advanced skills in Kubernetes resource organization, updates, and management. You're ready to handle production-level Kubernetes operations with confidence!

**💡 Pro Tip:** Practice these concepts in different combinations - create multi-tier applications across namespaces with proper labeling and update strategies. This will prepare you for real-world scenarios!
