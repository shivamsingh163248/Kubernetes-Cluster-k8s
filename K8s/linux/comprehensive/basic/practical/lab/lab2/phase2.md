# Phase 2: Basic Pod Operations

## Lab 2 – Create & Manage Pods

### Step 1: Create Your First Pod

**Theory:**

- A Pod is the smallest deployable unit in Kubernetes
- A Pod can have 1 or more containers (usually 1 for simple apps)
- The Pod is created using a YAML manifest

**Example: Simple Apache Pod (apache1.yaml)**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache1
  labels:
    app: apache
spec:
  containers:
  - name: apache-container
    image: httpd
    ports:
    - containerPort: 80
```

**Commands:**

```bash
# Apply pod manifest
kubectl apply -f apache1.yaml

# Check pods in default namespace
kubectl get pods

# Get detailed info
kubectl describe pod apache1
```

**Expected Output:**

**1. After applying the pod manifest:**
```bash
kubectl apply -f apache1.yaml
```
**Output:**
```
pod/apache1 created
```

**2. Check pod status:**
```bash
kubectl get pods
```
**Output:**
```
NAME      READY   STATUS    RESTARTS   AGE
apache1   1/1     Running   0          30s
```

👉 **Key parts explained:**
- **NAME**: apache1 → Pod name from metadata
- **READY**: 1/1 → 1 container ready out of 1 total
- **STATUS**: Running → Pod is successfully running
- **RESTARTS**: 0 → Number of container restarts
- **AGE**: 30s → Time since pod creation

**3. Get detailed pod information:**
```bash
kubectl get pods -o wide
```
**Output:**
```
NAME      READY   STATUS    RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
apache1   1/1     Running   0          45s   10.244.0.5   kind-control-plane   <none>           <none>
```

👉 **Additional details:**
- **IP**: 10.244.0.5 → Pod's internal cluster IP
- **NODE**: kind-control-plane → Which node is running this pod
- **NOMINATED NODE**: <none> → Advanced scheduling info
- **READINESS GATES**: <none> → Custom readiness conditions

✅ **Expected: Pod apache1 will start running in default namespace.**

### Step 2: Verify Pod & Namespace

**Theory:**

- By default, Pods are created in the default namespace
- You can check which namespace a Pod belongs to

**Commands:**

```bash
# List all pods in all namespaces
kubectl get pods -A

# Check only default namespace
kubectl get pods -n default
```

### Step 3: Check Pod → Node Mapping

**Theory:**

- Pods are scheduled by the scheduler onto Nodes
- You can see which Pod is running on which Node

**Command:**

```bash
kubectl get pods -o wide
```

✅ **This shows: Pod IP, Node name, container runtime.**

### Step 4: Access Pod Logs

**Theory:**

You can view logs from the container inside the Pod.

**Command:**

```bash
kubectl logs apache1
```

### Step 5: Exec into Pod Container

**Theory:**

We can enter into a Pod's container shell.

**Command:**

```bash
kubectl exec -it apache1 -- /bin/bash
```

### Step 6: Create Second Pod Manually

**Example: Another Apache Pod (apache2.yaml)**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache2
  labels:
    app: apache
spec:
  containers:
  - name: apache-container
    image: httpd
    ports:
    - containerPort: 80
```

**Commands:**

```bash
kubectl apply -f apache2.yaml
kubectl get pods
```

**Expected Output:**

**1. After applying apache2.yaml:**
```bash
kubectl apply -f apache2.yaml
```
**Output:**
```
pod/apache2 created
```

**2. Check both pods:**
```bash
kubectl get pods
```
**Output:**
```
NAME      READY   STATUS    RESTARTS   AGE
apache1   1/1     Running   0          2m15s
apache2   1/1     Running   0          15s
```

**3. View pods with labels:**
```bash
kubectl get pods --show-labels
```
**Output:**
```
NAME      READY   STATUS    RESTARTS   AGE     LABELS
apache1   1/1     Running   0          2m30s   app=apache,tier=web
apache2   1/1     Running   0          30s     app=apache,tier=web,version=v2
```

👉 **Key observations:**
- **Both pods running** → apache1 and apache2 are operational
- **Same app label** → Both have `app=apache` for service selection
- **Different versions** → apache2 has additional `version=v2` label
- **Age difference** → Shows creation timeline

**Now you'll have 2 Pods (apache1, apache2) both running in the cluster.**

### Step 7: Expose Pods with a Service

**Theory:**

- Pods are ephemeral (IP changes if restarted)
- To access them, we need a Service
- NodePort Service exposes Pods on a stable port

**Service (apache-service.yaml):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-service
spec:
  selector:
    app: apache
  ports:
  - protocol: TCP
    port: 8081
    targetPort: 80
  type: NodePort
```

**Commands:**

```bash
kubectl apply -f apache-service.yaml

# Check service details
kubectl get svc apache-service
```

**1. Check Service details again**

Run:

```bash
kubectl get svc apache-service -o wide
```

**Output looks like:**

```
NAME             TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
apache-service   NodePort   10.96.7.220   <none>        8081:32333/TCP   5s
```

👉 **Key part:**

- **port: 8081** → Service port (inside cluster)
- **NodePort: 32333** → Random port exposed on every Node

**2. Find your Node's IP**

Since you're running Kubernetes locally (Kind/Minikube) or on VM, you need the Node IP.

```bash
kubectl get nodes -o wide
```

**Example output:**

```
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP
kind-control-plane   Ready    control-plane   50m   v1.29.2   172.18.0.2
```

👉 **Node IP here is 172.18.0.2.**

**3. Curl the NodePort**

Now test:

```bash
curl http://<NODE-IP>:32333
```

**Example:**

```bash
curl http://172.18.0.2:32333
```

✅ **You should see Apache's default HTML page.**

### Step 8: Test Deployment (Instead of Manual Pods)

**Theory:**

- Instead of creating Pods manually, we use a Deployment
- Deployment manages replicas and ensures Pods are auto-healed

**Deployment (apache-deployment.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: apache-container
        image: httpd
        ports:
        - containerPort: 80
```

**Commands:**

```bash
kubectl apply -f apache-deployment.yaml

# Check deployment & pods
kubectl get deploy
kubectl get pods
```

**Expected Output:**

**1. After applying deployment:**
```bash
kubectl apply -f apache-deployment.yaml
```
**Output:**
```
deployment.apps/apache-deployment created
```

**2. Check deployment status:**
```bash
kubectl get deploy
```
**Output:**
```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
apache-deployment   2/2     2            2           45s
```

👉 **Deployment status explained:**
- **READY**: 2/2 → 2 pods ready out of 2 desired
- **UP-TO-DATE**: 2 → Pods with latest template
- **AVAILABLE**: 2 → Pods available for service
- **AGE**: 45s → Time since deployment creation

**3. Check all pods now:**
```bash
kubectl get pods
```
**Output:**
```
NAME                                 READY   STATUS    RESTARTS   AGE
apache1                              1/1     Running   0          5m
apache2                              1/1     Running   0          3m
apache-deployment-7d4c8b5f9b-k8n2m   1/1     Running   0          50s
apache-deployment-7d4c8b5f9b-x7p4q   1/1     Running   0          50s
```

👉 **Key differences:**
- **Manual pods** → apache1, apache2 (fixed names)
- **Deployment pods** → apache-deployment-xxx-yyy (generated names)
- **Total count** → Now 4 pods running (2 manual + 2 from deployment)

**4. View deployment-managed pods only:**
```bash
kubectl get pods -l app=apache
```
**Output shows all pods with app=apache label (manual + deployment pods)**

✅ **Kubernetes will automatically create 2 Apache Pods via Deployment.**

### Summary of Phase 2

| Concept | What You Learned | Command |
|---------|------------------|---------|
| **Pod** | Smallest unit | `kubectl get pods` |
| **Namespace** | Logical separation | `kubectl get pods -A` |
| **Node mapping** | Pod → Node | `kubectl get pods -o wide` |
| **Logs** | View app logs | `kubectl logs pod-name` |
| **Exec** | Enter container | `kubectl exec -it pod-name -- bash` |
| **Service** | Stable networking | `kubectl get svc` |
| **Deployment** | Auto-manage Pods | `kubectl get deploy` |

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
