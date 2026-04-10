#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../install_utils.sh"

configure_api_server() {
    log_info "Configuring MicroK8s API server..."
    
    local apiserver_config="/var/snap/microk8s/current/args/kube-apiserver"
    
    insert_text "--service-node-port-range" "--service-node-port-range=80-32000" "$apiserver_config" "true"
    
    log_success "API server configured"
}

configure_controller_manager() {
    log_info "Configuring MicroK8s controller manager..."
    
    local controller_config="/var/snap/microk8s/current/args/kube-controller-manager"
    
    insert_text "--terminated-pod-gc-threshold" "--terminated-pod-gc-threshold=200" "$controller_config" "true"
    
    log_success "Controller manager configured"
}

configure_kubelet() {
    log_info "Configuring MicroK8s kubelet..."
    
    local kubelet_config="/var/snap/microk8s/current/args/kubelet"
    
    insert_text "--max-pods" "--max-pods=250" "$kubelet_config" "true"
    
    log_success "Kubelet configured"
}

restart_microk8s() {
    log_info "Restarting MicroK8s to apply configuration changes..."
    
    microk8s stop
    sleep 5
    microk8s start
    
    log_info "Waiting for MicroK8s to be ready..."
    microk8s status --wait-ready
    
    log_success "MicroK8s restarted successfully"
}

verify_configuration() {
    log_info "Verifying MicroK8s configuration..."
    
    log_info "Checking API server configuration..."
    if sudo grep -q "service-node-port-range=80-32000" /var/snap/microk8s/current/args/kube-apiserver; then
        log_success "API server node port range configured correctly"
    else
        log_warning "API server node port range not configured"
    fi
    
    log_info "Checking controller manager configuration..."
    if sudo grep -q "terminated-pod-gc-threshold=200" /var/snap/microk8s/current/args/kube-controller-manager; then
        log_success "Controller manager pod GC threshold configured correctly"
    else
        log_warning "Controller manager pod GC threshold not configured"
    fi
    
    log_info "Checking kubelet configuration..."
    if sudo grep -q "max-pods=250" /var/snap/microk8s/current/args/kubelet; then
        log_success "Kubelet max pods configured correctly"
    else
        log_warning "Kubelet max pods not configured"
    fi
}

main() {
    log_info "Starting MicroK8s configuration..."
    
    configure_api_server
    configure_controller_manager
    configure_kubelet
    restart_microk8s
    verify_configuration
    
    log_success "MicroK8s configuration completed"
}

main "$@"
