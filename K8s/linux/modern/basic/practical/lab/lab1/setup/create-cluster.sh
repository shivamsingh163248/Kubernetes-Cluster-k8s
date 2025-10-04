#!/bin/bash

# Lab 1 Kubernetes Cluster Creation Script
# This script creates a Kind cluster and verifies it's working properly

set -e

echo "🚀 Creating Kubernetes Cluster for Lab 1"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLUSTER_NAME="mycluster"

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if cluster already exists
check_existing_cluster() {
    if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
        print_warning "Cluster '$CLUSTER_NAME' already exists"
        
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deleting existing cluster..."
            kind delete cluster --name $CLUSTER_NAME
        else
            print_status "Using existing cluster"
            return 0
        fi
    fi
}

# Create the cluster
create_cluster() {
    print_status "Creating Kind cluster '$CLUSTER_NAME'..."
    print_status "This may take a few minutes to download images and start components..."
    
    # Create cluster with custom configuration
    cat <<EOF | kind create cluster --name $CLUSTER_NAME --config -
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
EOF
    
    print_status "Cluster creation completed!"
}

# Verify cluster is working
verify_cluster() {
    print_status "Verifying cluster functionality..."
    
    # Check cluster info
    echo -n "  Cluster info: "
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        print_error "Failed to get cluster info"
        return 1
    fi
    
    # Check nodes
    echo -n "  Node status: "
    local node_status=$(kubectl get nodes --no-headers | awk '{print $2}')
    if [[ "$node_status" == "Ready" ]]; then
        echo -e "${GREEN}✓ Ready${NC}"
    else
        echo -e "${RED}✗ $node_status${NC}"
        print_error "Node is not ready"
        return 1
    fi
    
    # Check system pods
    echo -n "  System pods: "
    local pending_pods=$(kubectl get pods -n kube-system --no-headers | grep -v Running | grep -v Completed | wc -l)
    if [[ $pending_pods -eq 0 ]]; then
        echo -e "${GREEN}✓ All running${NC}"
    else
        echo -e "${YELLOW}⚠ $pending_pods pods not ready${NC}"
        print_warning "Some system pods are still starting"
    fi
}

# Display cluster information
display_cluster_info() {
    echo
    print_status "Cluster Information:"
    echo "===================="
    
    # Cluster context
    echo "Current context: $(kubectl config current-context)"
    
    # Node information
    echo
    echo "Nodes:"
    kubectl get nodes -o wide
    
    # System pods
    echo
    echo "System Pods:"
    kubectl get pods -n kube-system
    
    # Namespaces
    echo
    echo "Namespaces:"
    kubectl get namespaces
}

# Provide next steps
provide_next_steps() {
    echo
    echo -e "${BLUE}🎉 Cluster Setup Complete!${NC}"
    echo
    echo -e "${YELLOW}Your Kubernetes cluster is ready for Lab 1!${NC}"
    echo
    echo "Useful commands to remember:"
    echo "  kubectl cluster-info                    # Cluster information"
    echo "  kubectl get nodes                       # List nodes"
    echo "  kubectl get pods --all-namespaces      # List all pods"
    echo "  kubectl get namespaces                  # List namespaces"
    echo
    echo "To delete this cluster later:"
    echo "  kind delete cluster --name $CLUSTER_NAME"
    echo
    echo -e "${GREEN}Ready to start Lab 1 exercises!${NC}"
}

# Main function
main() {
    echo -e "${BLUE}Kubernetes Cluster Setup for Lab 1${NC}"
    echo "This script will create a local Kubernetes cluster using Kind"
    echo
    
    # Verify prerequisites
    if ! command -v kind &> /dev/null; then
        print_error "Kind is not installed. Please run ./install-prerequisites.sh first"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please run ./install-prerequisites.sh first"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not working. Please ensure Docker is running and you have permissions"
        exit 1
    fi
    
    # Confirm before proceeding
    read -p "Create Kubernetes cluster '$CLUSTER_NAME'? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cluster creation cancelled"
        exit 0
    fi
    
    check_existing_cluster
    create_cluster
    
    # Wait for cluster to be ready
    print_status "Waiting for cluster to be ready..."
    sleep 10
    
    verify_cluster
    display_cluster_info
    provide_next_steps
}

# Run main function
main "$@"
