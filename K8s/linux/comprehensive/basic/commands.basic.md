# Kubernetes Basic Commands Reference Guide

This comprehensive guide covers all essential Kubernetes commands with detailed explanations, flags, and examples. Perfect for beginners to understand what each command does and how to use it effectively.

## 📚 Table of Contents

1. [Cluster Management](#cluster-management)
2. [Node Operations](#node-operations)
3. [Pod Management](#pod-management)
4. [Service Operations](#service-operations)
5. [Deployment Commands](#deployment-commands)
6. [Namespace Management](#namespace-management)
7. [ConfigMap and Secret Operations](#configmap-and-secret-operations)
8. [Debugging and Troubleshooting](#debugging-and-troubleshooting)
9. [Resource Management](#resource-management)
10. [Advanced Operations](#advanced-operations)

---

## 🏗️ Cluster Management

### `kubectl cluster-info`
**Purpose**: Display cluster information including control plane and service endpoints

```bash
kubectl cluster-info
```

**Common Flags**:
- `--kubeconfig` → Specify path to kubeconfig file
- `--context` → Use specific context from kubeconfig

**Example**:
```bash
kubectl cluster-info --context=my-cluster
```

### `kubectl config`
**Purpose**: Manage kubeconfig files and contexts

```bash
# View current configuration
kubectl config view

# Get current context
kubectl config current-context

# Set default namespace for current context
kubectl config set-context --current --namespace=production

# Switch between contexts
kubectl config use-context my-other-cluster
```

**Important Flags**:
- `--current` → Apply to current context
- `--namespace` (short: `-n`) → Namespace (full form: namespace)
- `--context` → Specify context name

---

## 🖥️ Node Operations

### `kubectl get nodes`
**Purpose**: List all nodes in the cluster

```bash
kubectl get nodes
```

**Common Flags**:
- `-o wide` → Show additional information (IP addresses, OS, kernel)
- `-o yaml` → Output in YAML format
- `-o json` → Output in JSON format
- `--show-labels` → Display node labels
- `--selector` (short: `-l`) → Filter by labels

**Examples**:
```bash
# Basic node listing
kubectl get nodes

# Detailed node information
kubectl get nodes -o wide

# Filter nodes by label
kubectl get nodes -l kubernetes.io/arch=amd64

# Show all labels
kubectl get nodes --show-labels
```

### `kubectl describe node`
**Purpose**: Show detailed information about a specific node

```bash
kubectl describe node <node-name>
```

**Example**:
```bash
kubectl describe node kind-control-plane
```

---

## 🚀 Pod Management

### `kubectl get pods`
**Purpose**: List pods in current or specified namespace

```bash
kubectl get pods
```

**Essential Flags**:
- `-n` or `--namespace` → Specify namespace (full form: namespace)
- `--all-namespaces` (short: `-A`) → Show pods from all namespaces
- `-o wide` → Additional information (node, IP addresses)
- `--show-labels` → Display pod labels
- `-l` or `--selector` → Filter by label selector
- `-w` or `--watch` → Watch for changes in real-time

**Examples**:
```bash
# List pods in current namespace
kubectl get pods

# List pods in specific namespace
kubectl get pods -n kube-system

# List all pods across all namespaces
kubectl get pods --all-namespaces

# Show additional details
kubectl get pods -o wide

# Filter by labels
kubectl get pods -l app=nginx

# Watch pod changes
kubectl get pods -w
```

### `kubectl describe pod`
**Purpose**: Show detailed information about a specific pod

```bash
kubectl describe pod <pod-name>
```

**Common Flags**:
- `-n` or `--namespace` → Specify namespace

**Example**:
```bash
kubectl describe pod nginx-pod -n production
```

### `kubectl create pod`
**Purpose**: Create a pod (usually from YAML file)

```bash
kubectl create -f <file.yaml>
```

**Alternative - kubectl run** (Create pod directly):
```bash
kubectl run <pod-name> --image=<image-name>
```

**Examples**:
```bash
# Create from file
kubectl create -f nginx-pod.yaml

# Create pod directly
kubectl run test-pod --image=nginx:latest

# Create with specific port
kubectl run web-server --image=nginx --port=80

# Create and expose port
kubectl run api-server --image=node:alpine --port=3000 --expose
```

### `kubectl apply`
**Purpose**: Apply configuration from file (create or update)

```bash
kubectl apply -f <file.yaml>
```

**Important Flags**:
- `-f` or `--filename` → Specify file or directory
- `-n` or `--namespace` → Target namespace
- `--dry-run=client` → Preview changes without applying
- `-o yaml` → Show resulting YAML

**Examples**:
```bash
# Apply single file
kubectl apply -f deployment.yaml

# Apply all files in directory
kubectl apply -f ./manifests/

# Preview changes
kubectl apply -f deployment.yaml --dry-run=client

# Apply to specific namespace
kubectl apply -f pod.yaml -n development
```

### `kubectl delete pod`
**Purpose**: Delete one or more pods

```bash
kubectl delete pod <pod-name>
```

**Common Flags**:
- `-n` or `--namespace` → Specify namespace
- `-l` or `--selector` → Delete by label selector
- `--all` → Delete all pods in namespace
- `--force` → Force immediate deletion
- `--grace-period=0` → Skip graceful shutdown

**Examples**:
```bash
# Delete specific pod
kubectl delete pod nginx-pod

# Delete multiple pods
kubectl delete pod pod1 pod2 pod3

# Delete by label
kubectl delete pods -l app=nginx

# Delete all pods in namespace
kubectl delete pods --all -n test-namespace

# Force delete stuck pod
kubectl delete pod stuck-pod --force --grace-period=0
```

---

## 🌐 Service Operations

### `kubectl get services`
**Purpose**: List services in cluster

```bash
kubectl get services
```

**Short form**: `kubectl get svc`

**Common Flags**:
- `-n` or `--namespace` → Specify namespace
- `--all-namespaces` (short: `-A`) → All namespaces
- `-o wide` → Additional information
- `--show-labels` → Display service labels

**Examples**:
```bash
# List services in current namespace
kubectl get services

# Short form
kubectl get svc

# All namespaces
kubectl get svc --all-namespaces

# With additional details
kubectl get svc -o wide
```

### `kubectl describe service`
**Purpose**: Show detailed service information

```bash
kubectl describe service <service-name>
```

**Short form**: `kubectl describe svc <service-name>`

**Example**:
```bash
kubectl describe svc nginx-service -n production
```

### `kubectl expose`
**Purpose**: Create a service to expose pods

```bash
kubectl expose pod <pod-name> --port=80
```

**Important Flags**:
- `--port` → Service port
- `--target-port` → Pod port (if different from service port)
- `--type` → Service type (ClusterIP, NodePort, LoadBalancer)
- `--name` → Service name
- `--selector` → Label selector for pods

**Examples**:
```bash
# Expose pod with basic service
kubectl expose pod nginx-pod --port=80

# Expose with specific service type
kubectl expose pod web-app --port=80 --type=NodePort

# Expose deployment
kubectl expose deployment nginx-deployment --port=80 --target-port=8080

# Create LoadBalancer service
kubectl expose deployment api-server --port=80 --type=LoadBalancer
```

---

## 📦 Deployment Commands

### `kubectl get deployments`
**Purpose**: List deployments in cluster

```bash
kubectl get deployments
```

**Short form**: `kubectl get deploy`

**Common Flags**:
- `-n` or `--namespace` → Specify namespace
- `--all-namespaces` → All namespaces
- `-o wide` → Additional information
- `--show-labels` → Display labels

### `kubectl create deployment`
**Purpose**: Create a new deployment

```bash
kubectl create deployment <name> --image=<image>
```

**Important Flags**:
- `--image` → Container image
- `--replicas` → Number of pod replicas
- `--port` → Container port
- `--dry-run=client -o yaml` → Generate YAML without creating

**Examples**:
```bash
# Basic deployment
kubectl create deployment nginx-app --image=nginx

# With specific replicas
kubectl create deployment web-server --image=nginx --replicas=3

# Generate YAML file
kubectl create deployment api-app --image=node:alpine --dry-run=client -o yaml > deployment.yaml
```

### `kubectl scale deployment`
**Purpose**: Scale deployment replicas

```bash
kubectl scale deployment <name> --replicas=<number>
```

**Examples**:
```bash
# Scale to 5 replicas
kubectl scale deployment nginx-app --replicas=5

# Scale to 0 (stop all pods)
kubectl scale deployment api-server --replicas=0

# Scale with condition
kubectl scale deployment web-app --current-replicas=2 --replicas=3
```

### `kubectl rollout`
**Purpose**: Manage deployment rollouts

```bash
# Check rollout status
kubectl rollout status deployment/<name>

# View rollout history
kubectl rollout history deployment/<name>

# Rollback to previous version
kubectl rollout undo deployment/<name>

# Rollback to specific revision
kubectl rollout undo deployment/<name> --to-revision=2
```

**Examples**:
```bash
# Check if deployment is complete
kubectl rollout status deployment/nginx-app

# See deployment history
kubectl rollout history deployment/nginx-app

# Rollback last change
kubectl rollout undo deployment/nginx-app

# Restart deployment (rolling restart)
kubectl rollout restart deployment/nginx-app
```

---

## 📁 Namespace Management

### `kubectl get namespaces`
**Purpose**: List all namespaces in cluster

```bash
kubectl get namespaces
```

**Short form**: `kubectl get ns`

**Common Flags**:
- `--show-labels` → Display namespace labels
- `-o wide` → Additional information

### `kubectl create namespace`
**Purpose**: Create a new namespace

```bash
kubectl create namespace <name>
```

**Short form**: `kubectl create ns <name>`

**Examples**:
```bash
# Create namespace
kubectl create namespace development

# Short form
kubectl create ns production

# Create with labels
kubectl create ns testing --dry-run=client -o yaml | kubectl label --local -f - environment=test | kubectl apply -f -
```

### `kubectl delete namespace`
**Purpose**: Delete a namespace and all resources within it

```bash
kubectl delete namespace <name>
```

**⚠️ Warning**: This deletes ALL resources in the namespace!

**Example**:
```bash
kubectl delete ns old-project
```

---

## 🔧 ConfigMap and Secret Operations

### ConfigMaps

#### `kubectl get configmaps`
**Purpose**: List ConfigMaps

```bash
kubectl get configmaps
```

**Short form**: `kubectl get cm`

#### `kubectl create configmap`
**Purpose**: Create ConfigMap from various sources

```bash
# From literal values
kubectl create configmap <name> --from-literal=<key>=<value>

# From file
kubectl create configmap <name> --from-file=<file-path>

# From directory
kubectl create configmap <name> --from-file=<directory-path>
```

**Examples**:
```bash
# From literal values
kubectl create configmap app-config --from-literal=database_url=postgres://localhost --from-literal=debug=true

# From file
kubectl create configmap nginx-config --from-file=nginx.conf

# From multiple files
kubectl create configmap web-config --from-file=./config/
```

### Secrets

#### `kubectl get secrets`
**Purpose**: List secrets in namespace

```bash
kubectl get secrets
```

#### `kubectl create secret`
**Purpose**: Create secrets for sensitive data

```bash
# Generic secret
kubectl create secret generic <name> --from-literal=<key>=<value>

# Docker registry secret
kubectl create secret docker-registry <name> --docker-server=<server> --docker-username=<username> --docker-password=<password>

# TLS secret
kubectl create secret tls <name> --cert=<cert-file> --key=<key-file>
```

**Examples**:
```bash
# Database credentials
kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password=secret123

# Docker registry
kubectl create secret docker-registry my-registry --docker-server=registry.example.com --docker-username=myuser --docker-password=mypass

# TLS certificate
kubectl create secret tls my-tls-secret --cert=tls.crt --key=tls.key
```

---

## 🔍 Debugging and Troubleshooting

### `kubectl logs`
**Purpose**: View container logs

```bash
kubectl logs <pod-name>
```

**Essential Flags**:
- `-f` or `--follow` → Stream logs in real-time
- `-c` or `--container` → Specify container (for multi-container pods)
- `--previous` → Show logs from previous container instance
- `--since` → Show logs since specific time
- `--tail` → Show last N lines
- `-n` or `--namespace` → Specify namespace

**Examples**:
```bash
# Basic log viewing
kubectl logs nginx-pod

# Follow logs in real-time
kubectl logs -f api-server

# Logs from specific container
kubectl logs multi-container-pod -c web-server

# Previous container logs (useful for crashed containers)
kubectl logs crashed-pod --previous

# Last 50 lines
kubectl logs web-app --tail=50

# Logs since 1 hour ago
kubectl logs api-server --since=1h

# Logs from all pods with label
kubectl logs -l app=nginx
```

### `kubectl exec`
**Purpose**: Execute commands inside containers

```bash
kubectl exec <pod-name> -- <command>
```

**Important Flags**:
- `-it` → Interactive terminal (combined: -i for interactive, -t for TTY)
- `-c` or `--container` → Specify container name
- `-n` or `--namespace` → Specify namespace

**Examples**:
```bash
# Execute single command
kubectl exec nginx-pod -- ls /etc

# Interactive shell
kubectl exec -it nginx-pod -- /bin/bash

# Interactive shell in specific container
kubectl exec -it multi-pod -c web-server -- /bin/sh

# Execute command with output
kubectl exec nginx-pod -- cat /etc/nginx/nginx.conf

# Execute in specific namespace
kubectl exec -it debug-pod -n development -- bash
```

### `kubectl port-forward`
**Purpose**: Forward local port to pod or service

```bash
kubectl port-forward <resource> <local-port>:<remote-port>
```

**Examples**:
```bash
# Forward to pod
kubectl port-forward pod/nginx-pod 8080:80

# Forward to service
kubectl port-forward service/nginx-service 8080:80

# Forward to deployment
kubectl port-forward deployment/web-app 3000:3000

# Bind to all interfaces (not just localhost)
kubectl port-forward --address 0.0.0.0 pod/nginx-pod 8080:80
```

### `kubectl get events`
**Purpose**: View cluster events for troubleshooting

```bash
kubectl get events
```

**Useful Flags**:
- `--sort-by=.metadata.creationTimestamp` → Sort by time
- `-n` or `--namespace` → Specific namespace
- `--all-namespaces` → All namespaces
- `--field-selector` → Filter events

**Examples**:
```bash
# Recent events sorted by time
kubectl get events --sort-by=.metadata.creationTimestamp

# Events in specific namespace
kubectl get events -n kube-system

# All events across cluster
kubectl get events --all-namespaces

# Filter warning events
kubectl get events --field-selector type=Warning
```

---

## 📊 Resource Management

### `kubectl top`
**Purpose**: Show resource usage (requires metrics-server)

```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods

# Pod usage in specific namespace
kubectl top pods -n production

# Container-level usage
kubectl top pods --containers
```

### Resource Quotas and Limits

#### `kubectl get resourcequotas`
**Purpose**: View resource quotas in namespace

```bash
kubectl get resourcequotas
```

**Short form**: `kubectl get quota`

#### `kubectl describe resourcequota`
**Purpose**: Detailed quota information

```bash
kubectl describe resourcequota <quota-name>
```

---

## 🚀 Advanced Operations

### `kubectl patch`
**Purpose**: Update specific fields of resources

```bash
# Strategic merge patch
kubectl patch deployment nginx-app -p '{"spec":{"replicas":3}}'

# JSON patch
kubectl patch pod nginx-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"nginx:1.20"}]'
```

### `kubectl replace`
**Purpose**: Replace entire resource

```bash
kubectl replace -f updated-deployment.yaml
```

### `kubectl edit`
**Purpose**: Edit resource in default editor

```bash
kubectl edit deployment nginx-app
kubectl edit svc nginx-service -n production
```

### Label and Annotation Management

#### Adding Labels
```bash
# Add label to pod
kubectl label pod nginx-pod environment=production

# Add label to multiple pods
kubectl label pods -l app=nginx tier=frontend

# Overwrite existing label
kubectl label pod nginx-pod environment=staging --overwrite
```

#### Adding Annotations
```bash
# Add annotation
kubectl annotate pod nginx-pod description="Main web server"

# Remove annotation
kubectl annotate pod nginx-pod description-
```

---

## 🎯 Command Cheat Sheet

### Quick Reference

| Operation | Command | Short Form |
|-----------|---------|------------|
| Get resources | `kubectl get <resource>` | `kubectl get <short>` |
| Describe resource | `kubectl describe <resource> <name>` | - |
| Create resource | `kubectl create -f <file>` | - |
| Apply changes | `kubectl apply -f <file>` | - |
| Delete resource | `kubectl delete <resource> <name>` | - |
| View logs | `kubectl logs <pod>` | - |
| Execute command | `kubectl exec <pod> -- <cmd>` | - |
| Port forward | `kubectl port-forward <resource> <ports>` | - |

### Common Resource Types and Short Forms

| Resource | Short Form |
|----------|------------|
| pods | po |
| services | svc |
| deployments | deploy |
| replicasets | rs |
| namespaces | ns |
| configmaps | cm |
| secrets | secret |
| persistentvolumes | pv |
| persistentvolumeclaims | pvc |
| nodes | no |

### Essential Flag Meanings

| Flag | Full Form | Purpose |
|------|-----------|---------|
| `-n` | `--namespace` | Specify namespace |
| `-A` | `--all-namespaces` | All namespaces |
| `-l` | `--selector` | Label selector |
| `-o` | `--output` | Output format |
| `-f` | `--filename` | File path |
| `-w` | `--watch` | Watch for changes |
| `-it` | `--interactive --tty` | Interactive terminal |
| `--dry-run=client` | - | Preview without executing |

---

## 💡 Pro Tips

### 1. Use Aliases
Add these to your shell profile:
```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
```

### 2. Tab Completion
Enable kubectl tab completion:
```bash
# For bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc

# For zsh
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
```

### 3. Context and Namespace Management
```bash
# Quick namespace switching
kubectl config set-context --current --namespace=<namespace>

# View current context and namespace
kubectl config view --minify | grep -E 'current-context|namespace'
```

### 4. Useful Combinations
```bash
# Get all resources in namespace
kubectl get all -n <namespace>

# Delete everything in namespace
kubectl delete all --all -n <namespace>

# Get resource with custom columns
kubectl get pods -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName"

# Watch multiple resources
kubectl get pods,svc,deploy -w
```

---

**📚 This reference guide covers all essential Kubernetes commands with their flags and usage examples. Bookmark this page and refer back as you learn and practice with Kubernetes!**
