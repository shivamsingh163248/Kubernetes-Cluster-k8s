# Kubernetes Architecture - The Big Picture

Understanding Kubernetes architecture is crucial for effective usage. This document explains how all components work together to create a powerful container orchestration system.

## 🏗️ What is Kubernetes?

Kubernetes is a **container orchestration platform** that automates:
- Container deployment and scaling
- Load balancing and service discovery
- Storage management and networking
- Health monitoring and self-healing

Think of it as an **operating system for distributed applications**.

## 🎯 Cluster Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                   │
├─────────────────────────────────────────────────────────┤
│  CONTROL PLANE (Master)    │    WORKER NODES           │
│  ┌─────────────────────┐   │   ┌─────────────────────┐  │
│  │  • kube-apiserver   │   │   │  • kubelet          │  │
│  │  • etcd             │   │   │  • container runtime│  │
│  │  • kube-scheduler   │   │   │  • kube-proxy       │  │
│  │  • controller-mgr   │   │   │                     │  │
│  └─────────────────────┘   │   │  ┌─────┐ ┌─────┐    │  │
│                             │   │  │Pod 1│ │Pod 2│    │  │
│                             │   │  └─────┘ └─────┘    │  │
│                             │   └─────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 🧠 Control Plane Components

The Control Plane is the **brain** of your cluster. It makes decisions about where to run workloads and manages the overall cluster state.

### 1. kube-apiserver
- **Role**: Central hub for all cluster communication
- **Function**: REST API that processes all requests
- **Analogy**: Receptionist at a company - all requests go through here

```bash
# All kubectl commands talk to the API server
kubectl get pods  # → API server → etcd → return pod list
```

### 2. etcd
- **Role**: Cluster database
- **Function**: Stores all cluster state and configuration
- **Analogy**: Company's filing cabinet - stores all important information

**What's stored in etcd:**
- Node information
- Pod specifications
- Secrets and ConfigMaps
- Network configuration

### 3. kube-scheduler
- **Role**: Workload placement manager
- **Function**: Decides which node runs which pod
- **Analogy**: HR manager assigning work to employees

**Scheduling factors:**
- Node resources (CPU, memory)
- Pod requirements
- Node constraints and labels
- Load balancing

### 4. controller-manager
- **Role**: Maintains desired state
- **Function**: Continuously monitors and corrects cluster state
- **Analogy**: Supervisor ensuring work gets done correctly

**Example controllers:**
- **Deployment Controller**: Manages replica sets
- **Node Controller**: Monitors node health
- **Service Controller**: Manages load balancers

## 🏭 Worker Node Components

Worker nodes are where your applications actually run. They receive instructions from the control plane and execute them.

### 1. kubelet
- **Role**: Node agent
- **Function**: Manages containers on the node
- **Analogy**: Site manager executing instructions from headquarters

**Responsibilities:**
- Pulls container images
- Starts and stops containers
- Reports node and pod status
- Performs health checks

### 2. Container Runtime
- **Role**: Runs containers
- **Function**: Actually executes container processes
- **Examples**: Docker, containerd, CRI-O

```bash
# Kubelet tells container runtime:
# "Start this Apache container with these specifications"
```

### 3. kube-proxy
- **Role**: Network proxy
- **Function**: Handles networking and load balancing
- **Analogy**: Traffic controller directing network requests

**Functions:**
- Routes traffic to correct pods
- Load balances between pod replicas
- Handles service discovery

## 🔄 How Components Work Together

### Example: Deploying an Application

1. **User Action**:
   ```bash
   kubectl apply -f apache-deployment.yaml
   ```

2. **API Server**: Receives request, validates YAML, stores in etcd

3. **Controller Manager**: Deployment controller notices new deployment, creates ReplicaSet

4. **Scheduler**: Sees pending pods, assigns them to appropriate nodes

5. **kubelet**: On assigned nodes, pulls images and starts containers

6. **kube-proxy**: Updates network rules to route traffic to new pods

### Data Flow Diagram
```
User → kubectl → API Server → etcd
                     ↓
Controller Manager ← API Server → Scheduler
                     ↓
                  kubelet → Container Runtime
                     ↓
                 kube-proxy
```

## 🌐 Network Architecture

### Cluster Networking Model
- **Each Pod gets its own IP** (no NAT required)
- **Pods can communicate directly** (flat network)
- **Services provide stable endpoints** (load balancing)
- **Ingress handles external traffic** (HTTP/HTTPS routing)

### Network Layers
```
Internet → Ingress → Service → Pod → Container
```

## 🏷️ Node Types

### Master Node (Control Plane)
- **Purpose**: Management and decision making
- **Components**: API server, etcd, scheduler, controller-manager
- **Workloads**: Generally no user applications (production)

### Worker Node
- **Purpose**: Run application workloads
- **Components**: kubelet, container runtime, kube-proxy
- **Workloads**: Your applications run here

## 🔧 High Availability (HA) Architecture

In production, you typically have:
- **Multiple Master Nodes** (3 or 5 for HA)
- **Load Balancer** in front of API servers
- **Distributed etcd cluster**
- **Many Worker Nodes** for redundancy

```
         ┌─ Load Balancer ─┐
         │                │
    ┌─ Master 1 ──┐  ┌─ Master 2 ──┐
    │  etcd       │  │  etcd       │
    │  API Server │  │  API Server │
    └─────────────┘  └─────────────┘
         │                │
    ┌────┴────────────────┴────┐
    │     Worker Nodes         │
    │  ┌─────┐ ┌─────┐ ┌─────┐ │
    │  │Node1│ │Node2│ │Node3│ │
    └──┴─────┴─┴─────┴─┴─────┴─┘
```

## 💡 Key Takeaways

1. **Control Plane = Brain** → Makes decisions, stores state
2. **Worker Nodes = Muscle** → Execute workloads
3. **API Server = Central Hub** → All communication flows through here
4. **etcd = Memory** → Stores everything the cluster knows
5. **kubelet = Local Manager** → Executes instructions on each node

## 🚀 Next Steps

Now that you understand the architecture:
1. Read `02-core-concepts.md` to learn about Kubernetes objects
2. Practice creating clusters in `../practical/lab/lab1/`
3. Observe these components in action

---

**🧠 Remember**: Understanding the architecture helps you troubleshoot issues, optimize performance, and make better design decisions.
