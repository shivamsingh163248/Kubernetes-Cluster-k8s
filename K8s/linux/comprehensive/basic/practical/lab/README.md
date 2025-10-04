# Kubernetes Practical Labs - Comprehensive Guide

Welcome to the comprehensive Kubernetes hands-on labs! This directory contains practical exercises designed to take you from basic cluster setup to advanced Pod and Service operations.

## 🎯 Lab Overview

This lab series provides a structured learning path through Kubernetes fundamentals with real-world examples and expected outputs for every command.

### 📂 Lab Structure

```
lab/
├── lab1/                    # Phase 1: Environment Setup
│   ├── phase1.md           # Setup & Prerequisites
│   ├── setup/              # Installation scripts
│   └── exercises/          # Hands-on exercises
├── lab2/                   # Phase 2: Basic Pod Operations
│   ├── phase2.md          # Pod creation & management
│   ├── README.md          # Detailed lab guide
│   └── manifests/         # YAML configurations
└── README.md              # This overview file
```

---

## 🚀 Quick Start Guide

### Prerequisites Completed
- ✅ **Phase 1 completed** → Kubernetes cluster running
- ✅ **kubectl configured** → CLI access to cluster
- ✅ **Basic concepts understood** → Pods, Services, Deployments

### Verification Commands
```bash
# Ensure your environment is ready
kubectl cluster-info
kubectl get nodes
kind get clusters
```

---

## 🔹 Lab 1 – Pods (Deep Dive)

### Step 1: View all Pods in current namespace
```bash
kubectl get pods -o wide
```

✅ **Expected output:**

```
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE
apache1    1/1     Running   0          10m   10.244.0.12  kind-worker
apache2    1/1     Running   0          10m   10.244.0.13  kind-worker2
```

### Step 2: Describe a Pod
```bash
kubectl describe pod apache1
```

✅ **Check for:**

- **Labels** (app=apache)
- **Node** where Pod runs
- **Events** (Scheduled → Pulled image → Started container)

### Step 3: View Pod logs
```bash
kubectl logs apache1
```

✅ **You'll see Apache server logs.**

### Step 4: Exec into Pod
```bash
kubectl exec -it apache1 -- /bin/bash
```

**Inside Pod, check Apache files:**

```bash
ls /usr/local/apache2/htdocs
```

**Exit:**

```bash
exit
```

---

## 🔹 Lab 2 – Services (Pod ↔ Service Mapping)

### Step 1: Describe Service
```bash
kubectl describe svc apache-service
```

✅ **Expected part of output:**

```
Selector: app=apache
Endpoints: 10.244.0.12:80,10.244.0.13:80
```

👉 **These are Pod IPs linked by the Service.**

### Step 2: Check Endpoints object
```bash
kubectl get endpoints apache-service
```

✅ **Output:**

```
NAME             ENDPOINTS                        AGE
apache-service   10.244.0.12:80,10.244.0.13:80   20m
```

---

## 🔹 Lab 3 – Create a Deployment

Instead of creating Pods manually, use a Deployment.

**apache-deployment.yaml**

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

**Apply it:**

```bash
kubectl apply -f apache-deployment.yaml
```

**Check Deployment:**

```bash
kubectl get deploy
```

✅ **Output:**

```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
apache-deployment   2/2     2            2           10s
```

**Check Pods:**

```bash
kubectl get pods -o wide
```

---

## 🔹 Lab 4 – Expose Deployment via Service

```bash
kubectl expose deployment apache-deployment \
  --name=apache-service2 \
  --type=NodePort \
  --port=8081 \
  --target-port=80
```

**Check:**

```bash
kubectl get svc apache-service2
```

✅ **Output:**

```
NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
apache-service2   NodePort   10.96.23.105   <none>        8081:32567/TCP   5s
```

👉 **Note the NodePort (32567).**

**Test access:**

```bash
curl http://localhost:32567
```

✅ **Should return Apache index.html.**

---

## 🔹 Lab 5 – Scale the Deployment

**Increase replicas:**

```bash
kubectl scale deployment apache-deployment --replicas=5
```

**Check Pods:**

```bash
kubectl get pods -o wide
```

✅ **You'll see 5 Pods scheduled.**

---

## 🔹 Lab 6 – Delete Pods (Self-healing test)

**Delete a Pod manually:**

```bash
kubectl delete pod apache-deployment-xxxxx
```

**Check again:**

```bash
kubectl get pods
```

✅ **Kubernetes automatically creates a new Pod → Self-healing feature of Deployment.**

---

## ✅ Phase 2 Summary

| Concept | Purpose | Key Learning |
|---------|---------|--------------|
| **Pods** | Smallest unit, run containers | Manual lifecycle management |
| **Services** | Connect Pods (stable networking) | Label selectors, endpoint mapping |
| **Deployments** | Manage Pods (scaling, self-healing, rolling updates) | Automation, reliability, production-ready |

---

## 🎓 Learning Path Progression

### **Completed Skills Checklist:**
- ✅ **Pod Operations** → Create, inspect, debug, access containers
- ✅ **Service Networking** → ClusterIP, NodePort, endpoints, DNS
- ✅ **Deployment Management** → Scaling, self-healing, rolling updates
- ✅ **Troubleshooting** → Logs, describe, events, exec access

### **Next Steps:**
1. **Advanced Deployments** → Rolling updates, rollbacks
2. **ConfigMaps & Secrets** → Application configuration
3. **Persistent Volumes** → Data storage
4. **Ingress Controllers** → HTTP routing
5. **Monitoring & Observability** → Metrics, logging

---

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

#### **Pod Won't Start**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### **Service Not Accessible**
```bash
kubectl get endpoints <service-name>
kubectl describe service <service-name>
kubectl get pods -l <label-selector>
```

#### **Deployment Issues**
```bash
kubectl get deploy
kubectl describe deploy <deployment-name>
kubectl rollout status deployment/<deployment-name>
```

---

## 📚 Additional Resources

### **Documentation Links:**
- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)

### **Best Practices:**
- Always use Deployments for production workloads
- Set resource requests and limits
- Use meaningful labels and selectors
- Implement health checks and monitoring
- Follow the principle of least privilege

---

**🎉 Congratulations!** You've completed the comprehensive Kubernetes practical labs. You now have hands-on experience with the core building blocks of Kubernetes and are ready to tackle more advanced scenarios.

**💡 Pro Tip:** Keep practicing these fundamentals - they form the foundation for all advanced Kubernetes operations!