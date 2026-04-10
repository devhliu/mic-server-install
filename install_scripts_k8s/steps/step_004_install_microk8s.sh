#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../install_utils.sh"

MICROK8S_VERSION="${MICROK8S_VERSION:-1.28/stable}"
DNS_SERVER="${DNS_SERVER:-}"
GPU_ENABLED="${GPU_ENABLED:-true}"
OFFLINE_MODE="${OFFLINE_MODE:-false}"

install_microk8s() {
    log_info "Installing MicroK8s version: $MICROK8S_VERSION"
    
    if ! command -v snap &> /dev/null; then
        log_info "Installing snapd..."
        sudo apt-get update
        sudo apt-get install -y snapd
    fi
    
    log_info "Installing MicroK8s..."
    sudo snap install microk8s --classic --channel="$MICROK8S_VERSION"
    
    log_success "MicroK8s installed successfully"
}

configure_microk8s_permissions() {
    log_info "Configuring MicroK8s permissions..."
    
    log_info "Creating microk8s group..."
    sudo groupadd microk8s 2>/dev/null || true
    
    log_info "Adding user to microk8s group..."
    sudo usermod -aG microk8s "$USER"
    
    log_info "Configuring .kube directory..."
    mkdir -p "$HOME/.kube"
    sudo chown -f -R "$USER" "$HOME/.kube"
    
    log_success "MicroK8s permissions configured"
}

create_aliases() {
    log_info "Creating kubectl and helm aliases..."
    
    sudo snap alias microk8s.kubectl kubectl 2>/dev/null || true
    
    log_success "Aliases created"
}

wait_for_microk8s() {
    log_info "Waiting for MicroK8s to be ready..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if microk8s status --wait-ready 2>/dev/null; then
            log_success "MicroK8s is ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "Waiting for MicroK8s to be ready... (attempt $attempt/$max_attempts)"
        sleep 10
    done
    
    log_error "MicroK8s failed to start within timeout"
    return 1
}

enable_addons() {
    log_info "Enabling MicroK8s add-ons..."
    
    log_info "Enabling DNS..."
    if [ -n "$DNS_SERVER" ]; then
        microk8s enable dns:"$DNS_SERVER"
    else
        microk8s enable dns
    fi
    
    log_info "Enabling Helm 3..."
    microk8s enable helm3
    sudo snap alias microk8s.helm3 helm 2>/dev/null || true
    
    log_info "Enabling storage..."
    microk8s enable storage
    
    log_info "Enabling ingress..."
    microk8s enable ingress
    
    if [ "$GPU_ENABLED" = "true" ]; then
        log_info "Enabling GPU support..."
        if microk8s enable gpu 2>/dev/null; then
            log_success "GPU support enabled"
        else
            log_warning "GPU support not available or no GPU detected"
        fi
    fi
    
    log_success "Add-ons enabled successfully"
}

configure_pullk8s() {
    if [ "$OFFLINE_MODE" = "true" ]; then
        log_info "Installing pullk8s for China mirror access..."
        
        curl -L "https://raw.githubusercontent.com/OpsDocker/pullk8s/main/pullk8s.sh" -o /tmp/pullk8s.sh
        sudo mv /tmp/pullk8s.sh /usr/local/bin/pullk8s
        sudo chmod +x /usr/local/bin/pullk8s
        
        log_info "Pulling required images from China mirror..."
        pullk8s pull k8s.gcr.io/pause:3.1 --microk8s || true
        pullk8s pull k8s.gcr.io/metrics-server/metrics-server:v0.5.2 --microk8s || true
        
        log_success "Pullk8s configured and images pulled"
    fi
}

verify_microk8s() {
    log_info "Verifying MicroK8s installation..."
    
    log_info "MicroK8s status:"
    microk8s status
    
    log_info "MicroK8s nodes:"
    microk8s kubectl get nodes
    
    log_info "MicroK8s pods:"
    microk8s kubectl get pods --all-namespaces
    
    log_success "MicroK8s verification completed"
}

main() {
    log_info "Starting MicroK8s installation..."
    
    install_microk8s
    configure_microk8s_permissions
    create_aliases
    wait_for_microk8s
    enable_addons
    configure_pullk8s
    verify_microk8s
    
    log_success "MicroK8s installation completed"
    log_warning "Please log out and log back in for group changes to take effect."
}

main "$@"
