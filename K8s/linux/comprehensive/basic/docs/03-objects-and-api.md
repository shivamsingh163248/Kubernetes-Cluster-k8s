# Kubernetes Objects and API - Understanding the Interface

This document explains how Kubernetes objects work, how to interact with the API, and how to write effective YAML manifests.

## 🎯 Learning Objectives

After reading this document, you'll understand:
- Kubernetes API structure and versioning
- YAML manifest anatomy and best practices
- Object lifecycle and management
- kubectl command patterns

## 🏗️ Kubernetes API Structure

### API Groups and Versions
Kubernetes organizes its API into groups for better management and evolution:

```
/api/v1                          # Core API group
/apis/apps/v1                    # Apps API group
/apis/networking.k8s.io/v1       # Networking API group
/apis/storage.k8s.io/v1          # Storage API group
```

### API Group Examples
| Object Type | API Group | API Version | Kind |
|------------|-----------|-------------|------|
| Pod | Core (`""`) | `v1` | `Pod` |
| Deployment | `apps` | `v1` | `Deployment` |
| Service | Core (`""`) | `v1` | `Service` |
| Ingress | `networking.k8s.io` | `v1` | `Ingress` |

### API Versioning Stages
- **alpha** (v1alpha1) → Experimental, may be buggy
- **beta** (v1beta1) → Well-tested, but API may change
- **stable** (v1) → Production-ready, API is stable

## 📝 YAML Manifest Anatomy

### Basic Structure
Every Kubernetes object follows this structure:

```yaml
apiVersion: apps/v1              # API group and version
kind: Deployment                 # Object type
metadata:                        # Object identification
  name: my-app
  namespace: production
  labels:
    app: my-app
spec:                           # Desired state
  replicas: 3
  # ... specification details
status:                         # Current state (read-only)
  # Populated by Kubernetes
```

### The Four Essential Fields

#### 1. apiVersion
Specifies which API to use:
```yaml
# Core objects (Pod, Service, Namespace)
apiVersion: v1

# Deployments, ReplicaSets, DaemonSets
apiVersion: apps/v1

# Ingress
apiVersion: networking.k8s.io/v1
```

#### 2. kind
The type of object to create:
```yaml
kind: Pod           # Creates a Pod
kind: Deployment    # Creates a Deployment
kind: Service       # Creates a Service
```

#### 3. metadata
Object identification and organization:
```yaml
metadata:
  name: web-server              # Object name (required)
  namespace: production         # Namespace (optional, defaults to 'default')
  labels:                       # Key-value pairs for organization
    app: nginx
    tier: frontend
    environment: production
  annotations:                  # Additional metadata
    description: "Main web server"
    contact: "devops-team@company.com"
```

#### 4. spec
Desired state specification:
```yaml
spec:
  # Object-specific configuration
  # This varies by object type (Pod, Deployment, Service, etc.)
```

## 🎨 Writing Effective YAML Manifests

### Complete Pod Example
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: default
  labels:
    app: nginx
    tier: frontend
    version: "1.0"
  annotations:
    description: "Simple nginx web server"
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
      name: http
      protocol: TCP
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
    env:
    - name: NGINX_PORT
      value: "80"
    volumeMounts:
    - name: nginx-config
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: nginx-config
    configMap:
      name: nginx-config
  restartPolicy: Always
```

### Complete Deployment Example
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: production
  labels:
    app: nginx
    component: web-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
      component: web-server
  template:                     # Pod template
    metadata:
      labels:
        app: nginx
        component: web-server
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
        livenessProbe:          # Health check
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:         # Ready to serve traffic
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
  strategy:                     # Update strategy
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

### Complete Service Example
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: production
  labels:
    app: nginx
spec:
  selector:
    app: nginx
    component: web-server
  ports:
  - name: http
    protocol: TCP
    port: 80                    # Service port
    targetPort: 80              # Container port
  type: ClusterIP
```

## 🔄 Object Lifecycle Management

### Creating Objects
```bash
# Apply YAML file
kubectl apply -f deployment.yaml

# Create from stdin
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test
    image: nginx
EOF

# Create multiple objects
kubectl apply -f .              # All YAML files in directory
kubectl apply -f manifest/      # All files in manifest directory
```

### Viewing Objects
```bash
# List objects
kubectl get pods
kubectl get deployments
kubectl get services

# Detailed information
kubectl describe pod nginx-pod
kubectl describe deployment nginx-deployment

# YAML output
kubectl get pod nginx-pod -o yaml
kubectl get deployment nginx-deployment -o yaml

# JSON output
kubectl get pod nginx-pod -o json
```

### Updating Objects
```bash
# Apply changes from file
kubectl apply -f updated-deployment.yaml

# Direct edits
kubectl edit deployment nginx-deployment

# Patch specific fields
kubectl patch deployment nginx-deployment -p '{"spec":{"replicas":5}}'

# Replace entire object
kubectl replace -f deployment.yaml
```

### Deleting Objects
```bash
# Delete by name
kubectl delete pod nginx-pod
kubectl delete deployment nginx-deployment

# Delete by file
kubectl delete -f deployment.yaml

# Delete by label
kubectl delete pods -l app=nginx

# Delete all objects of a type
kubectl delete pods --all
```

## 🎯 kubectl Command Patterns

### Common Command Structure
```bash
kubectl [command] [type] [name] [flags]

# Examples:
kubectl get pods                    # List all pods
kubectl get pod nginx-pod          # Get specific pod
kubectl describe deployment my-app  # Describe deployment
kubectl delete service my-service   # Delete service
```

### Useful kubectl Flags
```bash
# Namespace operations
kubectl get pods -n production     # Specific namespace
kubectl get pods --all-namespaces  # All namespaces

# Output formats
kubectl get pods -o wide           # More columns
kubectl get pods -o yaml           # YAML format
kubectl get pods -o json           # JSON format

# Label operations
kubectl get pods -l app=nginx      # Filter by label
kubectl get pods --show-labels     # Show all labels

# Resource management
kubectl top pods                   # Resource usage
kubectl top nodes                  # Node resource usage
```

### Advanced kubectl Operations
```bash
# Port forwarding
kubectl port-forward pod/nginx-pod 8080:80
kubectl port-forward service/nginx-service 8080:80

# Execute commands in pods
kubectl exec -it nginx-pod -- /bin/bash
kubectl exec nginx-pod -- ls /etc

# Copy files
kubectl cp nginx-pod:/etc/nginx/nginx.conf ./nginx.conf
kubectl cp ./config.conf nginx-pod:/etc/config/

# Logs
kubectl logs nginx-pod             # Pod logs
kubectl logs -f nginx-pod          # Follow logs
kubectl logs nginx-pod --previous  # Previous container logs
```

## 📊 Object Status and Conditions

### Understanding Object Status
```yaml
status:
  conditions:
  - type: Available
    status: "True"
    lastUpdateTime: "2024-01-15T10:30:00Z"
    reason: MinimumReplicasAvailable
  - type: Progressing
    status: "True"
    lastUpdateTime: "2024-01-15T10:25:00Z"
    reason: NewReplicaSetAvailable
  replicas: 3
  readyReplicas: 3
  availableReplicas: 3
```

### Common Status Fields
| Field | Description |
|-------|-------------|
| `conditions` | Array of current object conditions |
| `phase` | Current lifecycle phase (Pod specific) |
| `replicas` | Total number of replicas |
| `readyReplicas` | Number of ready replicas |
| `availableReplicas` | Number of available replicas |

## 🔍 Debugging with kubectl

### Troubleshooting Workflow
```bash
# 1. Check object status
kubectl get pods
kubectl get deployments

# 2. Get detailed information
kubectl describe pod failing-pod

# 3. Check logs
kubectl logs failing-pod

# 4. Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# 5. Verify configuration
kubectl get pod failing-pod -o yaml
```

### Common Issues and Diagnostics

#### ImagePullBackOff
```bash
# Check image name and availability
kubectl describe pod failing-pod
# Look for: Failed to pull image, ErrImagePull, ImagePullBackOff
```

#### CrashLoopBackOff
```bash
# Check application logs
kubectl logs failing-pod --previous
# Application is crashing on startup
```

#### Pending Pods
```bash
# Check node resources and scheduling
kubectl describe pod pending-pod
# Look for: insufficient resources, node selectors, taints
```

## 📝 YAML Best Practices

### Organization and Structure
```yaml
# Use consistent indentation (2 spaces)
# Order sections logically: metadata, spec, status
# Use meaningful names and labels
# Include resource requests and limits
# Add health checks for production workloads
```

### Multi-Object Files
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  # ... deployment spec

---  # Document separator

apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  # ... service spec
```

### Environment-Specific Configurations
```bash
# Use different files for different environments
├── base/
│   ├── deployment.yaml
│   └── service.yaml
├── environments/
│   ├── development/
│   │   └── kustomization.yaml
│   └── production/
│       └── kustomization.yaml
```

## 💡 Advanced API Concepts

### Custom Resources
Kubernetes allows defining custom object types:
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: webapps.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
```

### API Discovery
```bash
# List all API versions
kubectl api-versions

# List all resource types
kubectl api-resources

# Get API documentation
kubectl explain pods
kubectl explain deployment.spec
```

## 🚀 Next Steps

Now that you understand the API and objects:
1. Read `04-networking-basics.md` for networking concepts
2. Practice creating objects in `../practical/lab/lab1/`
3. Experiment with different YAML configurations

---

**🎯 Key Takeaway**: The Kubernetes API provides a consistent, declarative interface for managing all cluster resources. Master the YAML structure and kubectl patterns to become effective with Kubernetes.
