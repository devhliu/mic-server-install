#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../install_utils.sh"

USE_CHINA_MIRROR="${USE_CHINA_MIRROR:-true}"

configure_apt_mirror() {
    log_info "Configuring APT mirror..."
    
    if [ "$USE_CHINA_MIRROR" = "true" ]; then
        log_info "Using Tsinghua mirror for China..."
        
        local sources_file="/etc/apt/sources.list.d/ubuntu.sources"
        
        if [ -f "$sources_file" ]; then
            log_info "Backing up $sources_file"
            sudo cp "$sources_file" "${sources_file}.backup"
            
            log_info "Configuring Tsinghua mirror..."
            sudo tee "$sources_file" > /dev/null << 'EOF'
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
            
            log_success "APT mirror configured successfully"
        else
            log_warning "Ubuntu 24.04 sources file not found, skipping mirror configuration"
        fi
    fi
}

update_system() {
    log_info "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    log_success "System updated successfully"
}

install_basic_packages() {
    log_info "Installing basic packages..."
    sudo apt-get install -y \
        curl \
        wget \
        git \
        vim \
        htop \
        net-tools \
        ca-certificates \
        gnupg \
        lsb-release
    log_success "Basic packages installed successfully"
}

configure_timezone() {
    log_info "Configuring timezone..."
    if [ -f /usr/bin/timedatectl ]; then
        sudo timedatectl set-timezone Asia/Shanghai
        log_success "Timezone configured to Asia/Shanghai"
    else
        log_warning "timedatectl not found, skipping timezone configuration"
    fi
}

configure_kernel_parameters() {
    log_info "Configuring kernel parameters..."
    
    insert_text "vm.max_map_count" "vm.max_map_count=262144" "/etc/sysctl.conf" "true"
    
    sudo sysctl -p
    
    log_success "Kernel parameters configured"
}

main() {
    log_info "Starting Ubuntu configuration..."
    
    configure_apt_mirror
    update_system
    install_basic_packages
    configure_timezone
    configure_kernel_parameters
    
    log_success "Ubuntu configuration completed"
}

main "$@"
