# Lab 2: Advanced Deployments, Services & Scaling

Welcome to Lab 2! Building on the foundation from Lab 1, this lab focuses on production-ready workload management using Deployments, advanced service configurations, scaling, and monitoring.

## 🎯 Lab Objectives

By the end of this lab, you will:
- ✅ Create and manage Deployments for production workloads
- ✅ Perform horizontal scaling operations
- ✅ Execute rolling updates and rollbacks
- ✅ Configure resource requests and limits
- ✅ Implement health checks (liveness and readiness probes)
- ✅ Set up advanced service configurations
- ✅ Monitor application performance and resource usage
- ✅ Troubleshoot deployment issues

## ⏱️ Estimated Duration: 1.5-2 hours

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

### Why Deployments Instead of Pods?

**Problem with Raw Pods:**
- Manual lifecycle management
- No automatic replacement if they fail
- No easy way to scale or update
- No rollback capabilities

**Deployment Benefits:**
- Automatic pod management and replacement
- Built-in scaling capabilities
- Rolling update strategy
- Rollback functionality
- Self-healing properties

### Exercise 1: Create Your First Deployment

**Step 1: Create Working Directory**

```bash
# Create lab2 workspace
mkdir -p ~/k8s-lab2
cd ~/k8s-lab2

# Create namespace for this lab
kubectl create namespace lab2
kubectl config set-context --current --namespace=lab2
```

**Step 2: Basic Deployment**

```bash
# Create nginx-deployment.yaml
cat > nginx-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
      tier: frontend
  template:
    metadata:
      labels:
        app: nginx
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
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

# Deploy the application
kubectl apply -f nginx-deployment.yaml

# Observe deployment creation
kubectl get deployments
kubectl get replicasets
kubectl get pods
```

**Step 3: Understanding the Hierarchy**

```bash
# See the relationship: Deployment → ReplicaSet → Pods
kubectl describe deployment nginx-deployment

# Check ReplicaSet details
kubectl get rs
kubectl describe rs $(kubectl get rs -o name | grep nginx)

# View pod details
kubectl get pods -l app=nginx --show-labels
```

### Exercise 2: Deployment Management Operations

**Step 1: Scaling Operations**

```bash
# Scale up to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# Watch the scaling process
kubectl get pods -w
# (Ctrl+C to stop watching)

# Verify final state
kubectl get deployment nginx-deployment
kubectl get pods -l app=nginx

# Scale down to 2 replicas
kubectl scale deployment nginx-deployment --replicas=2
kubectl get pods -l app=nginx
```

**Step 2: Update Deployment Image**

```bash
# Update to newer nginx version
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Watch the rolling update
kubectl rollout status deployment/nginx-deployment

# Check rollout history
kubectl rollout history deployment/nginx-deployment

# Verify updated pods
kubectl describe deployment nginx-deployment | grep Image
```

**Step 3: Rollback Operations**

```bash
# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Check rollback status
kubectl rollout status deployment/nginx-deployment

# View rollout history
kubectl rollout history deployment/nginx-deployment

# Verify rollback
kubectl describe deployment nginx-deployment | grep Image
```

---

## 📍 Phase 2: Advanced Service Configurations (20-25 minutes)

### Exercise 3: Multi-Service Architecture

**Step 1: Create Backend Deployment**

```bash
# Create backend-deployment.yaml
cat > backend-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  labels:
    app: backend
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
      tier: backend
  template:
    metadata:
      labels:
        app: backend
        tier: backend
    spec:
      containers:
      - name: backend
        image: httpd:latest
        ports:
        - containerPort: 80
        env:
        - name: BACKEND_PORT
          value: "80"
        resources:
          requests:
            memory: "32Mi"
            cpu: "100m"
          limits:
            memory: "64Mi"
            cpu: "200m"
EOF

# Deploy backend
kubectl apply -f backend-deployment.yaml
kubectl get deployments
kubectl get pods -l tier=backend
```

**Step 2: Create Services for Both Tiers**

```bash
# Create frontend-service.yaml
cat > frontend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  labels:
    app: nginx
    tier: frontend
spec:
  selector:
    app: nginx
    tier: frontend
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Create backend-service.yaml  
cat > backend-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  labels:
    app: backend
    tier: backend
spec:
  selector:
    app: backend
    tier: backend
  ports:
  - name: http
    protocol: TCP
    port: 8080
    targetPort: 80
  type: ClusterIP
EOF

# Deploy services
kubectl apply -f frontend-service.yaml
kubectl apply -f backend-service.yaml

# Verify services
kubectl get services
kubectl get endpoints
```

**Step 3: Test Service Discovery**

```bash
# Create debug pod for testing
cat > debug-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: debug-pod
spec:
  containers:
  - name: debug
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    stdin: true
    tty: true
EOF

# Deploy debug pod
kubectl apply -f debug-pod.yaml
kubectl wait --for=condition=ready pod/debug-pod

# Test service connectivity
kubectl exec -it debug-pod -- nslookup frontend-service
kubectl exec -it debug-pod -- nslookup backend-service
kubectl exec -it debug-pod -- curl http://frontend-service:80
kubectl exec -it debug-pod -- curl http://backend-service:8080
```

### Exercise 4: External Access Configuration

**Step 1: NodePort Service**

```bash
# Create external-service.yaml
cat > external-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-external
spec:
  selector:
    app: nginx
    tier: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

# Deploy external service
kubectl apply -f external-service.yaml
kubectl get services
```

**Step 2: Test External Access**

```bash
# Port forward for testing (Kind doesn't expose NodePorts directly)
kubectl port-forward service/nginx-external 8080:80 &

# Test access in new terminal
curl http://localhost:8080

# Stop port-forward
pkill -f "kubectl port-forward"
```

---

## 📍 Phase 3: Health Checks and Monitoring (25-30 minutes)

### Exercise 5: Implement Health Checks

**Step 1: Add Liveness and Readiness Probes**

```bash
# Create nginx-with-probes.yaml
cat > nginx-with-probes.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-with-probes
  labels:
    app: nginx-probes
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-probes
  template:
    metadata:
      labels:
        app: nginx-probes
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 10
EOF

# Deploy with health checks
kubectl apply -f nginx-with-probes.yaml

# Monitor pod startup and health
kubectl get pods -l app=nginx-probes -w
```

**Step 2: Simulate Health Check Failures**

```bash
# Create a deployment with intentional health check issues
cat > failing-healthcheck.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: failing-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: failing-app
  template:
    metadata:
      labels:
        app: failing-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /nonexistent
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /also-nonexistent  
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
EOF

# Deploy failing app
kubectl apply -f failing-healthcheck.yaml

# Observe the failure behavior
kubectl get pods -l app=failing-app
kubectl describe pod $(kubectl get pods -l app=failing-app -o name)

# Clean up failing app
kubectl delete deployment failing-app
```

### Exercise 6: Resource Management and Monitoring

**Step 1: Resource-Constrained Deployment**

```bash
# Create resource-demo.yaml
cat > resource-demo.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: resource-demo
  template:
    metadata:
      labels:
        app: resource-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          requests:
            memory: "16Mi"
            cpu: "50m"
          limits:
            memory: "32Mi"
            cpu: "100m"
        ports:
        - containerPort: 80
EOF

# Deploy resource-constrained app
kubectl apply -f resource-demo.yaml
kubectl get pods -l app=resource-demo
```

**Step 2: Monitor Resource Usage**

```bash
# Check resource usage (if metrics-server is available)
kubectl top nodes
kubectl top pods

# Describe deployment to see resource configuration
kubectl describe deployment resource-demo

# Check pod resource allocation
kubectl describe pod $(kubectl get pods -l app=resource-demo -o name | head -1)
```

**Step 3: Quality of Service Classes**

```bash
# Check QoS classes
kubectl get pods -l app=resource-demo -o custom-columns="NAME:.metadata.name,QOS:.status.qosClass"

# Compare with different resource configurations
kubectl get pods -l app=nginx -o custom-columns="NAME:.metadata.name,QOS:.status.qosClass"
```

---

## 📍 Phase 4: Advanced Deployment Strategies (20-25 minutes)

### Exercise 7: Rolling Update Strategies

**Step 1: Configure Rolling Update Strategy**

```bash
# Create strategic-deployment.yaml
cat > strategic-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strategic-app
  labels:
    app: strategic-app
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: strategic-app
  template:
    metadata:
      labels:
        app: strategic-app
        version: v1
    spec:
      containers:
      - name: app
        image: nginx:1.20
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

# Deploy strategic app
kubectl apply -f strategic-deployment.yaml
kubectl get pods -l app=strategic-app --show-labels
```

**Step 2: Perform Controlled Rolling Update**

```bash
# Update image and watch rolling update
kubectl set image deployment/strategic-app app=nginx:1.21

# Watch the rolling update in real-time
kubectl rollout status deployment/strategic-app

# Monitor pods during update
kubectl get pods -l app=strategic-app -w
# (Ctrl+C to stop)

# Check rollout history
kubectl rollout history deployment/strategic-app
```

**Step 3: Canary Deployment Simulation**

```bash
# Create canary version
cat > canary-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strategic-app-canary
  labels:
    app: strategic-app
    version: canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: strategic-app
      version: canary
  template:
    metadata:
      labels:
        app: strategic-app
        version: canary
    spec:
      containers:
      - name: app
        image: nginx:1.22
        ports:
        - containerPort: 80
EOF

# Deploy canary
kubectl apply -f canary-deployment.yaml

# Check both versions
kubectl get pods -l app=strategic-app --show-labels
kubectl get deployments -l app=strategic-app
```

---

## 📍 Phase 5: Troubleshooting and Monitoring (15-20 minutes)

### Exercise 8: Debugging Deployment Issues

**Step 1: Create Problematic Deployment**

```bash
# Create problematic-app.yaml
cat > problematic-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: problematic-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: problematic-app
  template:
    metadata:
      labels:
        app: problematic-app
    spec:
      containers:
      - name: app
        image: nginx:nonexistent-tag
        resources:
          requests:
            memory: "1Gi"
            cpu: "2000m"
EOF

# Deploy problematic app
kubectl apply -f problematic-app.yaml
```

**Step 2: Systematic Troubleshooting**

```bash
# Step 1: Check deployment status
kubectl get deployments

# Step 2: Check ReplicaSet
kubectl get rs

# Step 3: Check pods
kubectl get pods -l app=problematic-app

# Step 4: Describe deployment
kubectl describe deployment problematic-app

# Step 5: Describe failing pod
kubectl describe pod $(kubectl get pods -l app=problematic-app -o name | head -1)

# Step 6: Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Fix the issues
kubectl patch deployment problematic-app -p='{"spec":{"template":{"spec":{"containers":[{"name":"app","image":"nginx:1.21"}]}}}}'

kubectl patch deployment problematic-app -p='{"spec":{"template":{"spec":{"containers":[{"name":"app","resources":{"requests":{"memory":"64Mi","cpu":"250m"}}}]}}}}'

# Verify fix
kubectl get pods -l app=problematic-app
```

### Exercise 9: Performance Monitoring

**Step 1: Load Testing Setup**

```bash
# Create load test pod
cat > load-test.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: load-test
spec:
  containers:
  - name: curl
    image: curlimages/curl
    command: ["/bin/sh"]
    args:
    - -c
    - |
      while true; do
        curl -s http://frontend-service > /dev/null
        sleep 0.1
      done
EOF

# Deploy load test
kubectl apply -f load-test.yaml

# Monitor resource usage during load
kubectl top pods --containers
```

**Step 2: Scaling Under Load**

```bash
# Scale up during load test
kubectl scale deployment nginx-deployment --replicas=6

# Watch scaling
kubectl get pods -l app=nginx -w

# Scale back down
kubectl scale deployment nginx-deployment --replicas=3

# Clean up load test
kubectl delete pod load-test
```

---

## 📍 Phase 6: Cleanup and Review (10 minutes)

### Step 1: Comprehensive Cleanup

```bash
# List all resources in lab2 namespace
kubectl get all

# Delete deployments
kubectl delete deployment nginx-deployment backend-deployment nginx-with-probes resource-demo strategic-app strategic-app-canary problematic-app

# Delete services
kubectl delete service frontend-service backend-service nginx-external

# Delete remaining pods
kubectl delete pod debug-pod

# Switch back to default namespace
kubectl config set-context --current --namespace=default

# Delete lab2 namespace
kubectl delete namespace lab2

# Verify cleanup
kubectl get all -n lab2
```

### Step 2: Final Verification

```bash
# Check cluster status
kubectl get nodes
kubectl get namespaces

# Verify no resources remain from lab
kubectl get all --all-namespaces | grep -E "(nginx|backend|strategic|problematic)"
```

---

## 🎯 Lab Summary

### What You've Accomplished

✅ **Deployment Management**
- Created production-ready deployments
- Performed scaling operations
- Executed rolling updates and rollbacks
- Implemented deployment strategies

✅ **Advanced Services**
- Configured multi-tier service architecture
- Set up service discovery
- Implemented external access patterns
- Tested connectivity between services

✅ **Health and Monitoring**
- Added liveness, readiness, and startup probes
- Configured resource requests and limits
- Monitored resource usage
- Understood QoS classes

✅ **Troubleshooting**
- Diagnosed deployment issues
- Fixed configuration problems
- Performed systematic debugging
- Used monitoring tools effectively

### Key Concepts Mastered

**Deployment Features:**
- Replica management and scaling
- Rolling updates with zero downtime
- Rollback capabilities
- Self-healing properties

**Service Patterns:**
- Multi-service architectures
- Service discovery mechanisms
- External access configuration
- Load balancing strategies

**Operational Excellence:**
- Health check implementation
- Resource management
- Performance monitoring
- Systematic troubleshooting

---

## 🚀 Next Steps

### Production Readiness Checklist
- [ ] Resource requests and limits configured
- [ ] Health checks implemented
- [ ] Rolling update strategy defined
- [ ] Monitoring and alerting set up
- [ ] Backup and recovery planned

### Advanced Topics to Explore
1. **StatefulSets** → For stateful applications
2. **DaemonSets** → For node-level services
3. **Jobs and CronJobs** → For batch processing
4. **ConfigMaps and Secrets** → For configuration management
5. **Persistent Volumes** → For data storage
6. **Ingress Controllers** → For HTTP routing
7. **Network Policies** → for security
8. **RBAC** → For access control

### Real-World Applications
- Set up monitoring with Prometheus/Grafana
- Implement CI/CD pipelines
- Deploy to cloud providers (EKS, GKE, AKS)
- Learn Helm for package management
- Explore service mesh (Istio, Linkerd)

---

## 📚 Additional Resources

### Documentation
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Health Checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

### Best Practices
- Always set resource requests and limits
- Implement health checks for all applications
- Use rolling updates for zero-downtime deployments
- Monitor resource usage and performance
- Plan for disaster recovery

---

**🎉 Congratulations!** You've completed Lab 2 and now have solid skills in advanced Kubernetes operations. You're ready to deploy and manage production workloads with confidence!

**💡 Pro Tip**: Practice these concepts regularly and experiment with different configurations. The more you work with Kubernetes, the more intuitive these operations become.
