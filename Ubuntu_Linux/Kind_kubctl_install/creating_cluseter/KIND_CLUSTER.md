# KIND_CLUSTER.MD — Setting Up a Multi-Node Kubernetes Cluster using Kind

This guide provides step-by-step instructions to create a Kind cluster with 1 control-plane node and 3 worker nodes, including port mappings and specific node images.

---

## 🛠️ Prerequisites

Ensure you have the following installed:

- ✅ Docker (must be running)
- ✅ Kind
- ✅ kubectl (Kubernetes CLI)

If not installed, refer to:  
🔗 `install-kind-kubectl.sh` (Use a custom script to automate installation)

---

## 📝 Step 1: Create Kind Configuration File

Create a YAML file that defines your cluster structure:

### File: `kind-cluster-config.yaml`

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.31.2

  - role: worker
    image: kindest/node:v1.31.2

  - role: worker
    image: kindest/node:v1.31.2

  - role: worker
    image: kindest/node:v1.31.2
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
```

---

## 📂 Step 2: Save the Configuration

Save the file with the name:

```bash
kind-cluster-config.yaml
```

This YAML file defines:

- 1 control plane node
- 3 worker nodes
- Node image: `kindest/node:v1.31.2`
- Port 80 and 443 mappings on the last worker node

---

## 🚀 Step 3: Create the Kind Cluster

Use the following command to create your cluster from the config file:

```bash
kind create cluster --name my-cluster --config kind-cluster-config.yaml
```

This command will spin up all 4 nodes in Docker containers.

---

## ✅ Step 4: Verify Cluster Creation

Run this command to check if your nodes are up and running:

```bash
kubectl get nodes
```

You should see 4 nodes listed (1 control plane, 3 workers).

---

## 📌 Notes

- Port mappings allow you to access services on port 80 and 443 from your host.
- Ensure ports 80 and 443 are not already in use on your system.
- You can customize further:
  - Add Ingress support
  - Set node labels/taints
  - Use different Kubernetes versions

---

## 🔄 Cluster Lifecycle Commands

### ⛔ Delete the cluster:
```bash
kind delete cluster --name my-cluster
```

### 📦 List clusters:
```bash
kind get clusters
```

### 🐳 View Docker containers:
```bash
docker ps
```