#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

MICROK8S_VERSION="${MICROK8S_VERSION:-1.28/stable}"
DNS_SERVER="${DNS_SERVER:-}"
GPU_ENABLED="${GPU_ENABLED:-true}"
OFFLINE_MODE="${OFFLINE_MODE:-false}"

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install MicroK8s Kubernetes cluster with Docker and optional GPU support.

Options:
    --microk8s-version VERSION    MicroK8s version/channel (default: 1.28/stable)
    --dns-server IP              DNS server IP (default: auto-detect)
    --no-gpu                     Disable GPU support
    --offline                    Install in offline mode
    -h, --help                   Show this help message

Environment Variables:
    MICROK8S_VERSION    MicroK8s version/channel
    DNS_SERVER          DNS server IP address
    GPU_ENABLED         Enable GPU support (true/false)
    OFFLINE_MODE        Install in offline mode (true/false)

Examples:
    # Install with default settings
    $0

    # Install specific MicroK8s version
    $0 --microk8s-version 1.24/stable

    # Install with custom DNS
    $0 --dns-server 10.6.2.6

    # Install without GPU support
    $0 --no-gpu

    # Install in offline mode
    OFFLINE_MODE=true $0
EOF
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --microk8s-version)
                MICROK8S_VERSION="$2"
                shift 2
                ;;
            --dns-server)
                DNS_SERVER="$2"
                shift 2
                ;;
            --no-gpu)
                GPU_ENABLED="false"
                shift
                ;;
            --offline)
                OFFLINE_MODE="true"
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

run_installation_steps() {
    log_info "Starting MicroK8s installation..."
    log_info "MicroK8s version: $MICROK8S_VERSION"
    log_info "GPU support: $GPU_ENABLED"
    log_info "Offline mode: $OFFLINE_MODE"
    
    if [ -f "${SCRIPT_DIR}/steps/step_001_config_ubuntu.sh" ]; then
        log_info "Step 1: Configuring Ubuntu..."
        bash "${SCRIPT_DIR}/steps/step_001_config_ubuntu.sh"
    fi
    
    if [ -f "${SCRIPT_DIR}/steps/step_002_install_docker.sh" ]; then
        log_info "Step 2: Installing Docker..."
        bash "${SCRIPT_DIR}/steps/step_002_install_docker.sh"
    fi
    
    if [ "$GPU_ENABLED" = "true" ] && [ -f "${SCRIPT_DIR}/steps/step_003_install_nvidia_docker.sh" ]; then
        log_info "Step 3: Installing NVIDIA Docker..."
        bash "${SCRIPT_DIR}/steps/step_003_install_nvidia_docker.sh"
    fi
    
    if [ -f "${SCRIPT_DIR}/steps/step_004_install_microk8s.sh" ]; then
        log_info "Step 4: Installing MicroK8s..."
        MICROK8S_VERSION="$MICROK8S_VERSION" \
        DNS_SERVER="$DNS_SERVER" \
        GPU_ENABLED="$GPU_ENABLED" \
        OFFLINE_MODE="$OFFLINE_MODE" \
        bash "${SCRIPT_DIR}/steps/step_004_install_microk8s.sh"
    fi
    
    if [ -f "${SCRIPT_DIR}/steps/step_005_configure_microk8s.sh" ]; then
        log_info "Step 5: Configuring MicroK8s..."
        bash "${SCRIPT_DIR}/steps/step_005_configure_microk8s.sh"
    fi
    
    if [ -f "${SCRIPT_DIR}/steps/step_006_install_helm.sh" ]; then
        log_info "Step 6: Installing Helm..."
        bash "${SCRIPT_DIR}/steps/step_006_install_helm.sh"
    fi
    
    log_success "Installation completed successfully!"
    log_info "Please log out and log back in for group changes to take effect."
}

main() {
    parse_args "$@"
    run_installation_steps
}

main "$@"
