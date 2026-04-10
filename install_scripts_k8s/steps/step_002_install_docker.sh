#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../install_utils.sh"

OFFLINE_MODE="${OFFLINE_MODE:-false}"
DOCKER_VERSION="${DOCKER_VERSION:-}"

remove_old_docker() {
    log_info "Removing old Docker installations..."
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y "$pkg" 2>/dev/null || true
    done
    
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras 2>/dev/null || true
    sudo rm -rf /var/lib/docker 2>/dev/null || true
    sudo rm -rf /var/lib/containerd 2>/dev/null || true
    
    log_success "Old Docker installations removed"
}

install_docker_online() {
    log_info "Installing Docker using online method..."
    
    log_info "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    
    log_info "Adding Docker GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    log_info "Adding Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    log_info "Installing Docker Engine..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    log_success "Docker installed successfully"
}

install_docker_offline() {
    log_info "Installing Docker in offline mode..."
    
    local docker_urls="https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64"
    local tmp_dir="/tmp/docker-packages"
    
    sudo mkdir -p "$tmp_dir"
    cd "$tmp_dir"
    
    log_info "Downloading Docker packages..."
    sudo curl -fsSL "$docker_urls/containerd.io_1.7.25-1_amd64.deb" -o containerd.io_1.7.25-1_amd64.deb
    sudo curl -fsSL "$docker_urls/docker-buildx-plugin_0.21.1-1~ubuntu.24.04~noble_amd64.deb" -o docker-buildx-plugin_0.21.1-1~ubuntu.24.04~noble_amd64.deb
    sudo curl -fsSL "$docker_urls/docker-ce-cli_28.0.1-1~ubuntu.24.04~noble_amd64.deb" -o docker-ce-cli_28.0.1-1~ubuntu.24.04~noble_amd64.deb
    sudo curl -fsSL "$docker_urls/docker-ce-rootless-extras_28.0.1-1~ubuntu.24.04~noble_amd64.deb" -o docker-ce-rootless-extras_28.0.1-1~ubuntu.24.04~noble_amd64.deb
    sudo curl -fsSL "$docker_urls/docker-ce_28.0.1-1~ubuntu.24.04~noble_amd64.deb" -o docker-ce_28.0.1-1~ubuntu.24.04~noble_amd64.deb
    sudo curl -fsSL "$docker_urls/docker-compose-plugin_2.33.1-1~ubuntu.24.04~noble_amd64.deb" -o docker-compose-plugin_2.33.1-1~ubuntu.24.04~noble_amd64.deb
    
    log_info "Installing Docker packages..."
    sudo dpkg -i \
        containerd.io_1.7.25-1_amd64.deb \
        docker-buildx-plugin_0.21.1-1~ubuntu.24.04~noble_amd64.deb \
        docker-ce-cli_28.0.1-1~ubuntu.24.04~noble_amd64.deb \
        docker-ce-rootless-extras_28.0.1-1~ubuntu.24.04~noble_amd64.deb \
        docker-ce_28.0.1-1~ubuntu.24.04~noble_amd64.deb \
        docker-compose-plugin_2.33.1-1~ubuntu.24.04~noble_amd64.deb
    
    cd -
    sudo rm -rf "$tmp_dir"
    
    log_success "Docker installed successfully in offline mode"
}

configure_docker() {
    log_info "Configuring Docker..."
    
    log_info "Creating docker group..."
    sudo groupadd docker 2>/dev/null || true
    
    log_info "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    
    log_info "Creating .docker directory..."
    mkdir -p "$HOME/.docker"
    sudo chown -R "$USER:$USER" "$HOME/.docker"
    chmod g+rwx "$HOME/.docker" -R
    
    log_info "Enabling Docker service..."
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker.service
    
    log_success "Docker configured successfully"
}

verify_docker() {
    log_info "Verifying Docker installation..."
    
    if docker --version; then
        log_success "Docker is installed: $(docker --version)"
    else
        log_error "Docker installation failed"
        return 1
    fi
}

main() {
    log_info "Starting Docker installation..."
    
    remove_old_docker
    
    if [ "$OFFLINE_MODE" = "true" ]; then
        install_docker_offline
    else
        install_docker_online
    fi
    
    configure_docker
    verify_docker
    
    log_success "Docker installation completed"
    log_warning "Please log out and log back in for group changes to take effect."
}

main "$@"
