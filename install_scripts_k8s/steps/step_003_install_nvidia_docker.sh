#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../install_utils.sh"

check_nvidia_gpu() {
    log_info "Checking for NVIDIA GPU..."
    
    if lspci | grep -i nvidia > /dev/null 2>&1; then
        log_success "NVIDIA GPU detected"
        return 0
    else
        log_warning "No NVIDIA GPU detected"
        return 1
    fi
}

install_nvidia_docker() {
    log_info "Installing NVIDIA Container Toolkit..."
    
    log_info "Setting up NVIDIA package repository..."
    local distribution
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    
    log_info "Adding NVIDIA GPG key..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    
    log_info "Adding NVIDIA repository..."
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
    
    log_info "Updating package list..."
    sudo apt-get update
    
    log_info "Installing nvidia-docker2..."
    sudo apt-get install -y nvidia-docker2
    
    log_info "Configuring Docker runtime for NVIDIA..."
    sudo nvidia-ctk runtime configure --runtime=docker
    
    log_info "Restarting Docker service..."
    sudo systemctl restart docker
    
    log_success "NVIDIA Container Toolkit installed successfully"
}

verify_nvidia_docker() {
    log_info "Verifying NVIDIA Docker installation..."
    
    if command -v nvidia-ctk &> /dev/null; then
        log_success "NVIDIA Container Toolkit is installed"
        nvidia-ctk --version
    else
        log_error "NVIDIA Container Toolkit installation failed"
        return 1
    fi
}

test_nvidia_docker() {
    log_info "Testing NVIDIA Docker with a simple container..."
    
    if docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi; then
        log_success "NVIDIA Docker is working correctly"
    else
        log_warning "NVIDIA Docker test failed. This might be expected if no GPU is available."
    fi
}

main() {
    log_info "Starting NVIDIA Docker installation..."
    
    if ! check_nvidia_gpu; then
        log_warning "Skipping NVIDIA Docker installation (no GPU detected)"
        exit 0
    fi
    
    install_nvidia_docker
    verify_nvidia_docker
    test_nvidia_docker
    
    log_success "NVIDIA Docker installation completed"
}

main "$@"
