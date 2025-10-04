# Kubernetes Core Concepts - Essential Objects and Components

This document covers the fundamental building blocks of Kubernetes. Understanding these concepts is essential for working effectively with any Kubernetes cluster.

## 🎯 Learning Objectives

After reading this document, you'll understand:
- What Pods, Services, and Deployments are
- How Labels and Selectors work
- Namespace organization
- Resource management basics

## 📦 Pod - The Smallest Unit

### What is a Pod?
A **Pod** is the smallest deployable unit in Kubernetes. It's a wrapper around one or more containers that share:
- **Network** (same IP address)
- **Storage** (shared volumes)
- **Lifecycle** (created and destroyed together)

### Pod Characteristics
```yaml
# Simple Pod example
apiVersion: v1
kind: Pod
metadata:
  name: apache-pod
  labels:
    app: web-server
spec:
  containers:
  - name: apache
    image: httpd:latest
    ports:
    - containerPort: 80
```

### Key Points About Pods
- **Ephemeral** → Pods can be destroyed and recreated
- **Single IP** → All containers in a pod share one IP
- **Co-located** → Containers run on the same node
- **Atomic** → Entire pod succeeds or fails together

### When to Use Pods Directly
- **Development/Testing** → Quick deployments
- **Single-use Jobs** → Run-once tasks
- **Debugging** → Isolated testing

### Pod Lifecycle States
| State | Description | Next Action |
|-------|-------------|-------------|
| **Pending** | Waiting to be scheduled | Wait for node assignment |
| **Running** | At least one container running | Monitor health |
| **Succeeded** | All containers completed successfully | Clean up if needed |
| **Failed** | At least one container failed | Check logs, debug |
| **Unknown** | Pod state cannot be determined | Investigate node/network |

## 🚀 Deployment - Managing Pods at Scale

### What is a Deployment?
A **Deployment** manages a set of identical pods, providing:
- **Replica management** → Ensures desired number of pods
- **Rolling updates** → Zero-downtime updates
- **Self-healing** → Replaces failed pods automatically
- **Scaling** → Easy horizontal scaling

### Deployment Structure
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
spec:
  replicas: 3                    # How many pods to run
  selector:
    matchLabels:
      app: apache                # Which pods this manages
  template:                      # Pod template
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: apache
        image: httpd:latest
        ports:
        - containerPort: 80
```

### Deployment Benefits
- **High Availability** → Multiple pod replicas
- **Load Distribution** → Pods spread across nodes
- **Easy Scaling** → `kubectl scale deployment apache-deployment --replicas=5`
- **Version Control** → Rollback to previous versions
- **Health Management** → Replaces unhealthy pods

### Deployment vs Pod
| Aspect | Pod | Deployment |
|--------|-----|------------|
| **Use Case** | Single instance, testing | Production workloads |
| **Replicas** | Always 1 | 1 to N replicas |
| **Self-healing** | No | Yes |
| **Updates** | Manual recreation | Rolling updates |
| **Scaling** | Manual | Automatic/manual |

## 🌐 Service - Network Access to Pods

### What is a Service?
A **Service** provides stable network access to pods. Since pods are ephemeral (they come and go), services provide:
- **Stable IP address** → Doesn't change when pods restart
- **DNS name** → Access by name, not IP
- **Load balancing** → Distributes traffic across pods
- **Service discovery** → Other apps can find your service

### Service Types

#### 1. ClusterIP (Default)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-service
spec:
  selector:
    app: apache                  # Targets pods with this label
  ports:
  - protocol: TCP
    port: 80                     # Service port
    targetPort: 80               # Pod port
  type: ClusterIP                # Internal access only
```
**Use case**: Internal microservice communication

#### 2. NodePort
```yaml
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
    nodePort: 30080              # Access via Node:30080
  type: NodePort
```
**Use case**: External access during development

#### 3. LoadBalancer
```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-loadbalancer
spec:
  selector:
    app: apache
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer             # Cloud provider creates LB
```
**Use case**: Production external access (AWS ELB, GCP LB)

### Service Selection Process
1. **Service** uses **selector** to find pods
2. **Labels** on pods must match **selector**
3. **Service** routes traffic to all matching pods
4. **kube-proxy** handles the actual routing

## 🏷️ Labels and Selectors - Object Organization

### Labels
**Labels** are key-value pairs attached to objects for identification and organization.

```yaml
metadata:
  labels:
    app: apache
    environment: production
    tier: frontend
    version: "2.1"
```

### Common Label Patterns
- **app**: Application name (`app: apache`)
- **tier**: Application layer (`tier: frontend`)
- **environment**: Deployment environment (`environment: prod`)
- **version**: Application version (`version: "1.2.3"`)

### Selectors
**Selectors** use labels to identify which objects to target.

#### Equality-based Selectors
```yaml
selector:
  matchLabels:
    app: apache
    tier: frontend
```

#### Set-based Selectors
```yaml
selector:
  matchExpressions:
  - key: environment
    operator: In
    values: ["production", "staging"]
```

## 📁 Namespaces - Logical Clustering

### What are Namespaces?
**Namespaces** provide logical separation within a cluster:
- **Resource isolation** → Separate environments
- **Access control** → Different permissions per namespace
- **Resource quotas** → Limit resource usage
- **Name scoping** → Same names in different namespaces

### Default Namespaces
```bash
kubectl get namespaces
```

| Namespace | Purpose |
|-----------|---------|
| **default** | Default namespace for user objects |
| **kube-system** | System components (API server, etc.) |
| **kube-public** | Public information, readable by all |
| **kube-node-lease** | Node heartbeat information |

### Creating and Using Namespaces
```bash
# Create namespace
kubectl create namespace development

# Deploy to specific namespace
kubectl apply -f pod.yaml -n development

# Set default namespace for kubectl
kubectl config set-context --current --namespace=development
```

### Namespace Organization Strategies
```
production/     # Production workloads
├── frontend/   # Web services
├── backend/    # APIs and services
└── database/   # Data services

development/    # Development environment
├── feature-a/  # Feature branch testing
└── integration/ # Integration testing

monitoring/     # Observability tools
├── prometheus/ # Metrics
├── grafana/    # Dashboards
└── logging/    # Log aggregation
```

## 🔄 How Objects Work Together

### Example: Complete Application Stack
```yaml
# 1. Deployment (manages pods)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      tier: frontend
  template:
    metadata:
      labels:
        app: web
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest

---
# 2. Service (exposes deployment)
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: production
spec:
  selector:
    app: web
    tier: frontend
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

### Object Relationships
```
Namespace
    └── Deployment
            └── ReplicaSet (created automatically)
                    └── Pod 1 (labeled: app=web, tier=frontend)
                    └── Pod 2 (labeled: app=web, tier=frontend)
                    └── Pod 3 (labeled: app=web, tier=frontend)
    └── Service
            └── Selects pods with labels: app=web, tier=frontend
```

## 📊 Resource Management

### Resource Requests and Limits
```yaml
spec:
  containers:
  - name: apache
    image: httpd:latest
    resources:
      requests:          # Minimum guaranteed resources
        memory: "128Mi"
        cpu: "100m"
      limits:            # Maximum allowed resources
        memory: "256Mi"
        cpu: "500m"
```

### Quality of Service (QoS) Classes
| QoS Class | Condition | Behavior |
|-----------|-----------|----------|
| **Guaranteed** | Requests = Limits | Highest priority, last to be evicted |
| **Burstable** | Requests < Limits | Medium priority |
| **BestEffort** | No requests/limits | Lowest priority, first to be evicted |

## 🔍 Troubleshooting Core Concepts

### Common Issues and Solutions

#### Pod Won't Start
```bash
# Check pod status
kubectl get pod apache-pod

# Check events and logs
kubectl describe pod apache-pod
kubectl logs apache-pod
```

#### Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints apache-service

# Verify label matching
kubectl get pods --show-labels
kubectl describe service apache-service
```

#### Deployment Not Scaling
```bash
# Check deployment status
kubectl get deployment apache-deployment
kubectl describe deployment apache-deployment

# Check replica set
kubectl get replicaset
```

## 💡 Best Practices

### Label Strategy
- **Use consistent labels** across all objects
- **Include environment, app, and version** labels
- **Use meaningful names** for easy filtering

### Resource Management
- **Always set resource requests** for production
- **Set appropriate limits** to prevent resource starvation
- **Monitor resource usage** regularly

### Namespace Organization
- **Use namespaces for environments** (dev, staging, prod)
- **Implement resource quotas** per namespace
- **Set up appropriate RBAC** permissions

## 🚀 Next Steps

Now that you understand core concepts:
1. Read `03-objects-and-api.md` for API details
2. Practice in `../practical/lab/lab1/` with hands-on exercises
3. Experiment with different configurations

---

**🎯 Key Takeaway**: These core concepts work together to provide a powerful, flexible platform for running containerized applications at scale.
