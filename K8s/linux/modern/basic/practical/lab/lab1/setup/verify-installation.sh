#!/bin/bash

# Lab 1 Installation Verification Script
# This script verifies that all required tools are properly installed and working

set -e

echo "🔍 Verifying Kubernetes Lab 1 Prerequisites"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0

# Function to run verification tests
verify_command() {
    local cmd_name=$1
    local cmd_check=$2
    local expected_pattern=$3
    
    echo -n "Checking $cmd_name... "
    
    if command -v $cmd_check &> /dev/null; then
        local version_output=$($cmd_check 2>&1 || true)
        if [[ $version_output =~ $expected_pattern ]]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            echo "  $version_output"
            ((PASSED++))
        else
            echo -e "${RED}✗ FAILED${NC}"
            echo "  Unexpected output: $version_output"
            ((FAILED++))
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Command not found: $cmd_check"
        ((FAILED++))
    fi
    echo
}

# Function to check Docker daemon
verify_docker_daemon() {
    echo -n "Checking Docker daemon... "
    
    if sudo systemctl is-active docker &> /dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        echo "  Docker daemon is running"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Docker daemon is not running"
        echo "  Try: sudo systemctl start docker"
        ((FAILED++))
    fi
    echo
}

# Function to check Docker permissions
verify_docker_permissions() {
    echo -n "Checking Docker permissions... "
    
    if docker ps &> /dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        echo "  Can run Docker commands without sudo"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ WARNING${NC}"
        echo "  Cannot run Docker without sudo"
        echo "  You may need to logout and login again"
        echo "  Or run: sudo usermod -aG docker \$USER"
        ((FAILED++))
    fi
    echo
}

# Function to check system resources
verify_system_resources() {
    echo "Checking system resources..."
    
    # RAM check
    local total_ram=$(free -m | grep '^Mem:' | awk '{print $2}')
    echo -n "  RAM (minimum 4GB): "
    if [[ $total_ram -ge 4096 ]]; then
        echo -e "${GREEN}✓ ${total_ram}MB${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ ${total_ram}MB (below recommended 4GB)${NC}"
        ((FAILED++))
    fi
    
    # Disk space check
    local available_space=$(df / | awk 'NR==2 {print $4}')
    local available_gb=$((available_space / 1024 / 1024))
    echo -n "  Disk space (minimum 20GB): "
    if [[ $available_gb -ge 20 ]]; then
        echo -e "${GREEN}✓ ${available_gb}GB available${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ ${available_gb}GB available (below recommended 20GB)${NC}"
        ((FAILED++))
    fi
    
    # CPU cores check
    local cpu_cores=$(nproc)
    echo -n "  CPU cores (minimum 2): "
    if [[ $cpu_cores -ge 2 ]]; then
        echo -e "${GREEN}✓ ${cpu_cores} cores${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ ${cpu_cores} cores (below recommended 2)${NC}"
        ((FAILED++))
    fi
    echo
}

# Function to test basic functionality
verify_basic_functionality() {
    echo "Testing basic functionality..."
    
    # Test kubectl help
    echo -n "  kubectl help: "
    if kubectl help &> /dev/null; then
        echo -e "${GREEN}✓ Working${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ Failed${NC}"
        ((FAILED++))
    fi
    
    # Test kind help
    echo -n "  kind help: "
    if kind help &> /dev/null; then
        echo -e "${GREEN}✓ Working${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ Failed${NC}"
        ((FAILED++))
    fi
    
    # Test Docker info (if permissions work)
    echo -n "  docker info: "
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓ Working${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ Permission issue${NC}"
        ((FAILED++))
    fi
    echo
}

# Main verification function
main() {
    echo -e "${BLUE}Starting comprehensive verification...${NC}"
    echo
    
    # Tool version checks
    verify_command "Docker" "docker --version" "Docker version"
    verify_command "kubectl" "kubectl version --client" "Client Version"
    verify_command "Kind" "kind version" "kind"
    
    # Service and permission checks
    verify_docker_daemon
    verify_docker_permissions
    
    # System resource checks
    verify_system_resources
    
    # Basic functionality tests
    verify_basic_functionality
    
    # Summary
    echo "======================================"
    echo "Verification Summary:"
    echo -e "  ${GREEN}Passed: $PASSED${NC}"
    echo -e "  ${RED}Failed: $FAILED${NC}"
    echo
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All verifications passed! You're ready for Lab 1!${NC}"
        echo
        echo -e "${YELLOW}Next steps:${NC}"
        echo "1. Run ./create-cluster.sh to create your Kubernetes cluster"
        echo "2. Start the Lab 1 exercises!"
        exit 0
    else
        echo -e "${RED}❌ Some verifications failed. Please fix the issues above.${NC}"
        echo
        echo -e "${YELLOW}Common fixes:${NC}"
        echo "- Logout and login again (for Docker group membership)"
        echo "- Run: sudo systemctl start docker"
        echo "- Check available system resources"
        echo "- Re-run ./install-prerequisites.sh if tools are missing"
        exit 1
    fi
}

# Run main function
main "$@"
