# Phase 1: Setup & Pre-requisites

## Lab 1 – Environment Setup

### Step 1: Install Prerequisites (Theory + Commands)

**Theory:**

Before creating a Kubernetes cluster locally (using Kind or Minikube), we need these tools:

- **Docker** → Container runtime that runs your application containers (Pods run inside containers)
- **kubectl** → Kubernetes CLI to interact with the cluster (apply YAMLs, get pods, describe nodes, etc.)
- **Kind** → "Kubernetes in Docker" tool to create a local Kubernetes cluster using Docker containers as nodes
- **curl, conntrack, apt-transport-https, ca-certificates** → Supporting utilities required for downloading and running tools

**Commands: Ubuntu/Debian Example**

```bash
# Update system packages
sudo apt update -y

# Install supporting utilities
sudo apt install -y curl apt-transport-https ca-certificates conntrack

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker
docker --version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/
kind version
```

✅ **Step 1 complete: All prerequisites installed.**

### Step 2: Create a Kubernetes Cluster with Kind

**Theory:**

- Kind creates a Kubernetes cluster locally
- Uses Docker containers to simulate nodes
- By default, one control-plane node is created

**Command:**

```bash
# Create a cluster named "mycluster"
kind create cluster --name mycluster

# List nodes in cluster
kubectl get nodes
```

**Expected Output:**

```
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   1m    v1.xx.x
```

**Explanation:**

- **Cluster** → All nodes + control plane
- **Control Plane** → Brain of the cluster
- **Node** → Worker machine (in Kind, a Docker container)

### Step 3: Verify Cluster Components

**Theory:**

We need to make sure Control Plane and cluster services are working.

**Commands:**

```bash
# Check cluster info
kubectl cluster-info

# Check all pods running in all namespaces
kubectl get pods -A

# List namespaces
kubectl get ns
```

**Key namespaces to know:**

- **default** → default namespace for user objects
- **kube-system** → system pods like kube-dns, scheduler, controller
- **kube-public** → public info accessible to all
- **kube-node-lease** → node heartbeat info

### Step 4: Explore the Node

**Theory:**

- Node is the worker machine (Docker container in Kind)
- Runs kubelet, container runtime, kube-proxy

**Command:**

```bash
kubectl get nodes -o wide
```

**Check:**
- Node name
- Status
- Internal IP
- Roles

### Step 5: Test kubectl Connectivity

**Theory:**

kubectl talks to the kube-apiserver on the control plane to manage cluster objects.

**Commands:**

```bash
kubectl version
kubectl cluster-info
kubectl get nodes
```

✅ **This ensures kubectl is correctly configured to manage the cluster.**

### Step 6: Understanding Pod Scheduling (No Pods Yet)

**Theory:**

- When we later create a Pod, the Control Plane decides which Node runs the Pod
- Node must have kubelet + container runtime to run the Pod

**Check nodes again:**

```bash
kubectl get nodes -o wide
```

### Step 7: Check Logs and Node Details

```bash
# Describe node (details about resources, labels, conditions)
kubectl describe node kind-control-plane
```

**Resources:** CPU, memory
**Labels:** Identify node for scheduling
**Conditions:** Ready, disk pressure, etc.

### Step 8: Summary of Phase 1

| Concept | Description | Command/Check |
|---------|-------------|---------------|
| **Cluster** | All nodes + control plane | `kubectl cluster-info` |
| **Control Plane** | Brain of the cluster | Runs kube-apiserver, etcd, scheduler, controller-manager |
| **Node** | Worker machine | `kubectl get nodes` |
| **kubelet** | Node agent | `kubectl describe node <node>` |
| **Container runtime** | Runs actual containers | Docker installed on node |
| **Namespace** | Logical separation | `kubectl get ns` |
| **Verify cluster** | All system pods running | `kubectl get pods -A` |

✅ **Phase 1 complete: Cluster created, Control Plane verified, Node running.**
