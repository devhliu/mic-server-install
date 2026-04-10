#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../install_utils.sh"

HELM_VERSION="${HELM_VERSION:-3.13.0}"

install_helm() {
    log_info "Installing Helm..."
    
    if command -v helm &> /dev/null; then
        log_warning "Helm is already installed: $(helm version --short)"
        return 0
    fi
    
    local tmp_dir="/tmp/helm-install"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir"
    
    log_info "Downloading Helm $HELM_VERSION..."
    curl -fsSL "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" -o get_helm.sh
    chmod 700 get_helm.sh
    
    log_info "Running Helm installer..."
    ./get_helm.sh --version "v$HELM_VERSION"
    
    cd -
    rm -rf "$tmp_dir"
    
    log_success "Helm installed successfully"
}

configure_helm() {
    log_info "Configuring Helm..."
    
    log_info "Adding stable repository..."
    helm repo add stable https://charts.helm.sh/stable 2>/dev/null || true
    
    log_info "Adding bitnami repository..."
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
    
    log_info "Updating Helm repositories..."
    helm repo update
    
    log_success "Helm configured successfully"
}

verify_helm() {
    log_info "Verifying Helm installation..."
    
    if command -v helm &> /dev/null; then
        log_success "Helm is installed: $(helm version --short)"
        
        log_info "Helm repositories:"
        helm repo list
        
        log_success "Helm verification completed"
    else
        log_error "Helm installation failed"
        return 1
    fi
}

main() {
    log_info "Starting Helm installation..."
    
    install_helm
    configure_helm
    verify_helm
    
    log_success "Helm installation completed"
}

main "$@"
