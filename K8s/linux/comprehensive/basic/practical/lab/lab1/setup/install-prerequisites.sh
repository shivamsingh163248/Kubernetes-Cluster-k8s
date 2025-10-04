#!/bin/bash

# Lab 1 Prerequisites Installation Script
# This script installs Docker, kubectl, and Kind on Ubuntu/Debian systems

set -e  # Exit on any error

echo "🚀 Starting Kubernetes Lab 1 Prerequisites Installation"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported OS
check_os() {
    if [[ -f /etc/lsb-release ]]; then
        . /etc/lsb-release
        if [[ $DISTRIB_ID != "Ubuntu" ]]; then
            print_warning "This script is optimized for Ubuntu. Continuing anyway..."
        fi
    elif [[ -f /etc/debian_version ]]; then
        print_status "Detected Debian-based system"
    else
        print_error "Unsupported operating system"
        exit 1
    fi
}

# Update system packages
update_system() {
    print_status "Updating system packages..."
    sudo apt update -y
    sudo apt install -y curl apt-transport-https ca-certificates conntrack
}

# Install Docker
install_docker() {
    print_status "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_warning "Docker is already installed"
        docker --version
        return
    fi
    
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    print_status "Docker installed successfully"
    docker --version
    print_warning "You may need to logout and login again for Docker group membership to take effect"
}

# Install kubectl
install_kubectl() {
    print_status "Installing kubectl..."
    
    if command -v kubectl &> /dev/null; then
        print_warning "kubectl is already installed"
        kubectl version --client
        return
    fi
    
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Make executable and move to PATH
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    print_status "kubectl installed successfully"
    kubectl version --client
}

# Install Kind
install_kind() {
    print_status "Installing Kind..."
    
    if command -v kind &> /dev/null; then
        print_warning "Kind is already installed"
        kind version
        return
    fi
    
    # Download Kind
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
    
    # Make executable and move to PATH
    chmod +x kind
    sudo mv kind /usr/local/bin/
    
    print_status "Kind installed successfully"
    kind version
}

# Check system requirements
check_requirements() {
    print_status "Checking system requirements..."
    
    # Check RAM
    total_ram=$(free -m | grep '^Mem:' | awk '{print $2}')
    if [[ $total_ram -lt 4096 ]]; then
        print_warning "System has less than 4GB RAM (${total_ram}MB). Minimum 4GB recommended."
    else
        print_status "RAM: ${total_ram}MB ✓"
    fi
    
    # Check disk space
    available_space=$(df / | awk 'NR==2 {print $4}')
    available_gb=$((available_space / 1024 / 1024))
    if [[ $available_gb -lt 20 ]]; then
        print_warning "Less than 20GB free disk space available (${available_gb}GB)"
    else
        print_status "Disk space: ${available_gb}GB available ✓"
    fi
    
    # Check CPU cores
    cpu_cores=$(nproc)
    if [[ $cpu_cores -lt 2 ]]; then
        print_warning "System has less than 2 CPU cores (${cpu_cores}). Performance may be limited."
    else
        print_status "CPU cores: ${cpu_cores} ✓"
    fi
}

# Main installation flow
main() {
    echo -e "${BLUE}Kubernetes Lab 1 Prerequisites Installer${NC}"
    echo "This script will install Docker, kubectl, and Kind"
    echo
    
    # Confirm before proceeding
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled"
        exit 0
    fi
    
    check_os
    check_requirements
    update_system
    install_docker
    install_kubectl
    install_kind
    
    echo
    print_status "✅ Prerequisites installation completed successfully!"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Logout and login again (for Docker group membership)"
    echo "2. Run ./verify-installation.sh to verify all tools"
    echo "3. Run ./create-cluster.sh to create your Kubernetes cluster"
    echo "4. Start Lab 1 exercises!"
}

# Run main function
main "$@"
