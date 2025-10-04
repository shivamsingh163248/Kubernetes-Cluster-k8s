# Kubernetes Networking Basics - Communication and Connectivity

This document covers fundamental networking concepts in Kubernetes, including how pods communicate, service discovery, and traffic routing.

## 🎯 Learning Objectives

After reading this document, you'll understand:
- Kubernetes networking model and principles
- How pods communicate with each other
- Service types and their use cases
- DNS resolution and service discovery
- Basic network troubleshooting

## 🌐 Kubernetes Networking Model

### Core Networking Principles

Kubernetes follows these fundamental networking rules:

1. **Every Pod gets its own IP address**
2. **Pods can communicate with each other directly** (no NAT)
3. **All nodes can communicate with all pods** (and vice versa)
4. **The IP that a pod sees itself as is the same IP others see it as**

### Network Architecture Overview
```
┌─────────────────────────────────────────────────────────┐
│                    CLUSTER NETWORK                      │
│                                                         │
│  ┌─────────────┐              ┌─────────────┐          │
│  │    Node 1   │              │    Node 2   │          │
│  │             │              │             │          │
│  │ ┌─────────┐ │              │ ┌─────────┐ │          │
│  │ │Pod A    │ │              │ │Pod C    │ │          │
│  │ │10.1.1.2 │ │◄────────────►│ │10.1.2.3 │ │          │
│  │ └─────────┘ │              │ └─────────┘ │          │
│  │ ┌─────────┐ │              │ ┌─────────┐ │          │
│  │ │Pod B    │ │              │ │Pod D    │ │          │
│  │ │10.1.1.3 │ │◄────────────►│ │10.1.2.4 │ │          │
│  │ └─────────┘ │              │ └─────────┘ │          │
│  └─────────────┘              └─────────────┘          │
└─────────────────────────────────────────────────────────┘
```

## 📡 Pod-to-Pod Communication

### Same Node Communication
Pods on the same node communicate through:
- **Linux bridge** (docker0 or similar)
- **Virtual ethernet pairs** (veth)
- **Direct IP routing**

```bash
# Inside Pod A (10.1.1.2)
curl http://10.1.1.3:80  # Direct access to Pod B
```

### Cross-Node Communication
Pods on different nodes communicate through:
- **Overlay networks** (Flannel, Calico, Weave)
- **Cloud networking** (AWS VPC, GCP VPC)
- **Physical network routing**

```bash
# Inside Pod A (Node 1: 10.1.1.2)
curl http://10.1.2.3:80  # Access to Pod C on Node 2
```

### Container-to-Container (Same Pod)
Containers in the same pod share:
- **Network namespace** → Same IP address
- **Localhost communication** → Use 127.0.0.1
- **Port space** → Cannot use the same port

```bash
# Container 1 in Pod
curl http://localhost:3000  # Access Container 2 in same pod
```

## 🎯 Services - Stable Network Endpoints

### Why Services Are Needed

**Problem**: Pods are ephemeral (they die and get recreated with new IPs)
**Solution**: Services provide stable endpoints that don't change

### Service Discovery Flow
```
Client → Service (stable IP/DNS) → Pod 1 (ephemeral IP)
                                → Pod 2 (ephemeral IP)
                                → Pod 3 (ephemeral IP)
```

## 🔧 Service Types Deep Dive

### 1. ClusterIP Service (Default)

**Purpose**: Internal cluster communication only

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - protocol: TCP
    port: 80           # Service port
    targetPort: 8080   # Pod port
  type: ClusterIP      # Internal only
```

**Use Cases**:
- Microservice communication
- Database access from applications
- Internal APIs

**Access Pattern**:
```bash
# From any pod in the cluster
curl http://backend-service:80
curl http://backend-service.default.svc.cluster.local:80
```

### 2. NodePort Service

**Purpose**: External access through node ports

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080    # External port (30000-32767)
  type: NodePort
```

**Access Pattern**:
```bash
# From outside the cluster
curl http://<node-ip>:30080
curl http://<any-node-ip>:30080  # Works on any node
```

**Use Cases**:
- Development and testing
- Simple external access
- Legacy applications

### 3. LoadBalancer Service

**Purpose**: Cloud provider load balancer integration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
spec:
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

**What Happens**:
1. Kubernetes requests a load balancer from cloud provider
2. Cloud creates external load balancer (AWS ELB, GCP LB)
3. Load balancer routes traffic to node ports
4. Nodes forward traffic to pods

**Use Cases**:
- Production web applications
- Public APIs
- Applications needing high availability

### 4. ExternalName Service

**Purpose**: DNS alias for external services

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: my-database.company.com
```

**Use Cases**:
- Legacy system integration
- External database access
- Third-party service integration

## 🔍 DNS and Service Discovery

### DNS Names in Kubernetes

Every service gets DNS names in these formats:

```
# Within same namespace
<service-name>

# Cross-namespace access
<service-name>.<namespace>

# Fully qualified domain name
<service-name>.<namespace>.svc.cluster.local
```

### Example DNS Resolution
```yaml
# Service in 'production' namespace
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: production
```

**DNS Names**:
- From same namespace: `api-service`
- From other namespaces: `api-service.production`
- Full FQDN: `api-service.production.svc.cluster.local`

### Testing DNS Resolution
```bash
# From within a pod
nslookup api-service
nslookup api-service.production
nslookup api-service.production.svc.cluster.local

# Check all service endpoints
kubectl get endpoints api-service
```

## ⚡ Service Load Balancing

### Default Load Balancing
- **Algorithm**: Round-robin by default
- **Session Affinity**: None (each request to different pod)
- **Health Checks**: Only routes to healthy pods

### Session Affinity Configuration
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
  sessionAffinity: ClientIP  # Stick to same pod
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800  # 3 hours
```

### External Traffic Policy
```yaml
spec:
  type: NodePort
  externalTrafficPolicy: Local  # Preserve source IP
  # vs Cluster (default, may change source IP)
```

## 🔗 Advanced Networking Concepts

### Ingress - HTTP/HTTPS Routing

**Ingress** provides HTTP/HTTPS routing to services:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

**Traffic Flow**:
```
Internet → Ingress Controller → Service → Pod
```

### Network Policies - Security

**Network Policies** control traffic between pods:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-netpol
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## 🛠️ Network Troubleshooting

### Common Networking Issues

#### 1. Service Not Accessible
```bash
# Check service exists
kubectl get service my-service

# Check endpoints
kubectl get endpoints my-service

# Verify pod labels match service selector
kubectl get pods --show-labels
kubectl describe service my-service
```

#### 2. DNS Resolution Failure
```bash
# Test from within a pod
kubectl exec -it test-pod -- nslookup kubernetes.default

# Check DNS pod status
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

#### 3. Pod-to-Pod Communication Issues
```bash
# Test direct IP access
kubectl get pods -o wide
kubectl exec -it pod-a -- curl http://<pod-b-ip>:8080

# Check network policies
kubectl get networkpolicy
```

### Debugging Tools

#### Network Debugging Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    stdin: true
    tty: true
```

```bash
# Deploy and use for testing
kubectl apply -f netshoot.yaml
kubectl exec -it netshoot -- bash

# Inside the pod - various network tools available
nslookup kubernetes.default
curl http://service-name:port
ping pod-ip
traceroute external-host
```

#### Useful Commands
```bash
# Check cluster DNS configuration
kubectl get configmap coredns -n kube-system -o yaml

# View service endpoints
kubectl get endpoints --all-namespaces

# Check node networking
kubectl get nodes -o wide

# Network plugin information
kubectl get daemonsets -n kube-system
```

## 📊 Port and Protocol Management

### Port Types in Kubernetes

```yaml
spec:
  containers:
  - name: web
    ports:
    - name: http           # Named port
      containerPort: 80    # Port inside container
      protocol: TCP        # TCP or UDP
    - name: metrics
      containerPort: 9090
      protocol: TCP
```

### Service Port Configuration
```yaml
spec:
  ports:
  - name: http
    port: 80             # Service port (cluster internal)
    targetPort: http     # Can reference named port
    nodePort: 30080      # External port (NodePort only)
    protocol: TCP
```

### Multi-Port Services
```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
spec:
  selector:
    app: web
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  - name: metrics
    port: 9090
    targetPort: 9090
```

## 🚀 Best Practices

### Service Design
- **Use named ports** for clarity and flexibility
- **Implement health checks** for service endpoints
- **Use appropriate service types** for each use case
- **Design for service discovery** using DNS names

### Network Security
- **Implement Network Policies** in production
- **Use TLS/SSL** for sensitive communication
- **Limit external access** to necessary services only
- **Regular security audits** of network policies

### Performance Optimization
- **Keep related services close** (same namespace/node)
- **Use ClusterIP** for internal communication
- **Monitor network latency** and throughput
- **Optimize pod placement** with node affinity

## 🚀 Next Steps

Now that you understand Kubernetes networking:
1. Practice creating different service types in `../practical/lab/lab1/`
2. Experiment with DNS resolution and service discovery
3. Set up ingress controllers for HTTP routing
4. Explore network policies for security

---

**🌐 Key Takeaway**: Kubernetes networking provides a flat, simple model where every pod can communicate with every other pod. Services add stability and load balancing, while DNS enables easy service discovery.
