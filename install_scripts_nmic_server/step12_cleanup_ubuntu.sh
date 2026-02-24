#!/usr/bin/env bash
set -euo pipefail

print_header() {
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

print_header "Ubuntu System Cleanup Utility"
echo "This script will clean various download caches from:"
echo "  - apt (Ubuntu package manager)"
echo "  - conda (Miniconda/Anaconda)"
echo "  - pip (Python package manager)"
echo "  - npm/npx (Node.js package manager)"
echo "  - Hugging Face (model downloads)"
echo "  - wget/curl (temporary downloads)"
echo ""

show_disk_usage() {
    echo ""
    echo "Current disk usage for cache directories:"
    echo "----------------------------------------"
    
    local total=0
    
    if [ -d "/var/cache/apt" ]; then
        local apt_size=$(sudo du -sh /var/cache/apt 2>/dev/null | cut -f1)
        echo "  apt cache:           ${apt_size}"
    fi
    
    if [ -d "/opt/miniconda3/pkgs" ]; then
        local conda_size=$(sudo du -sh /opt/miniconda3/pkgs 2>/dev/null | cut -f1)
        echo "  conda packages:      ${conda_size}"
    fi
    
    if [ -d "${HOME}/.cache/pip" ]; then
        local pip_size=$(du -sh "${HOME}/.cache/pip" 2>/dev/null | cut -f1)
        echo "  pip cache:           ${pip_size}"
    fi
    
    if [ -d "${HOME}/.npm" ]; then
        local npm_size=$(du -sh "${HOME}/.npm" 2>/dev/null | cut -f1)
        echo "  npm cache:           ${npm_size}"
    fi
    
    if [ -d "${HOME}/.cache/huggingface" ]; then
        local hf_size=$(du -sh "${HOME}/.cache/huggingface" 2>/dev/null | cut -f1)
        echo "  Hugging Face cache:  ${hf_size}"
    fi
    
    if [ -d "/tmp" ]; then
        local tmp_size=$(sudo du -sh /tmp 2>/dev/null | cut -f1)
        echo "  /tmp directory:      ${tmp_size}"
    fi
    
    echo ""
}

show_disk_usage

cleanup_apt() {
    print_header "[1/6] Cleaning apt cache"
    
    echo "Running apt-get clean..."
    sudo apt-get clean
    
    echo "Running apt-get autoclean..."
    sudo apt-get autoclean
    
    echo "Running apt-get autoremove..."
    sudo apt-get autoremove -y
    
    echo "apt cache cleaned."
}

cleanup_conda() {
    print_header "[2/6] Cleaning conda cache"
    
    local conda_bin="/opt/miniconda3/bin/conda"
    
    if [ -x "${conda_bin}" ]; then
        echo "Cleaning conda package cache..."
        sudo "${conda_bin}" clean --all -y
        
        echo "Removing conda tarballs..."
        sudo rm -rf /opt/miniconda3/pkgs/*.tar.bz2 2>/dev/null || true
        sudo rm -rf /opt/miniconda3/pkgs/*.tar.xz 2>/dev/null || true
        
        echo "conda cache cleaned."
    else
        echo "conda not found at ${conda_bin}, skipping."
    fi
}

cleanup_pip() {
    print_header "[3/6] Cleaning pip cache"
    
    local pip_bin="/opt/miniconda3/bin/pip"
    
    if [ -x "${pip_bin}" ]; then
        echo "Running pip cache purge..."
        sudo "${pip_bin}" cache purge 2>/dev/null || echo "pip cache purge not supported or already empty."
    fi
    
    echo "Removing pip cache directory..."
    sudo rm -rf "${HOME}/.cache/pip" 2>/dev/null || true
    sudo rm -rf /root/.cache/pip 2>/dev/null || true
    
    echo "pip cache cleaned."
}

cleanup_npm() {
    print_header "[4/6] Cleaning npm/npx cache"
    
    local npm_bin="/opt/node/v22.20.0/bin/npm"
    
    if [ -x "${npm_bin}" ]; then
        echo "Running npm cache clean --force..."
        sudo "${npm_bin}" cache clean --force 2>/dev/null || true
    fi
    
    echo "Removing npm cache directory..."
    sudo rm -rf "${HOME}/.npm" 2>/dev/null || true
    sudo rm -rf /root/.npm 2>/dev/null || true
    
    echo "Removing npx cache..."
    sudo rm -rf "${HOME}/.npm/_npx" 2>/dev/null || true
    sudo rm -rf /root/.npm/_npx 2>/dev/null || true
    
    echo "npm/npx cache cleaned."
}

cleanup_huggingface() {
    print_header "[5/6] Cleaning Hugging Face cache"
    
    echo "Removing Hugging Face cache directory..."
    sudo rm -rf "${HOME}/.cache/huggingface" 2>/dev/null || true
    sudo rm -rf /root/.cache/huggingface 2>/dev/null || true
    
    echo "Hugging Face cache cleaned."
}

cleanup_temp_files() {
    print_header "[6/6] Cleaning temporary download files"
    
    echo "Removing wget/curl downloaded files in /tmp..."
    sudo rm -f /tmp/*.tar.gz 2>/dev/null || true
    sudo rm -f /tmp/*.tar.xz 2>/dev/null || true
    sudo rm -f /tmp/*.tar.bz2 2>/dev/null || true
    sudo rm -f /tmp/*.zip 2>/dev/null || true
    sudo rm -f /tmp/*.sh 2>/dev/null || true
    sudo rm -f /tmp/miniconda3-installer.sh 2>/dev/null || true
    sudo rm -f /tmp/node-*.tar.xz 2>/dev/null || true
    sudo rm -rf /tmp/node-v* 2>/dev/null || true
    
    echo "Removing old journal logs..."
    sudo journalctl --vacuum-time=3d 2>/dev/null || true
    
    echo "Temporary files cleaned."
}

show_final_disk_usage() {
    print_header "Cleanup Complete"
    
    echo ""
    echo "Final disk usage for cache directories:"
    echo "----------------------------------------"
    
    if [ -d "/var/cache/apt" ]; then
        local apt_size=$(sudo du -sh /var/cache/apt 2>/dev/null | cut -f1)
        echo "  apt cache:           ${apt_size}"
    fi
    
    if [ -d "/opt/miniconda3/pkgs" ]; then
        local conda_size=$(sudo du -sh /opt/miniconda3/pkgs 2>/dev/null | cut -f1)
        echo "  conda packages:      ${conda_size}"
    fi
    
    if [ -d "${HOME}/.cache/pip" ]; then
        local pip_size=$(du -sh "${HOME}/.cache/pip" 2>/dev/null | cut -f1)
        echo "  pip cache:           ${pip_size}"
    else
        echo "  pip cache:           0 (cleaned)"
    fi
    
    if [ -d "${HOME}/.npm" ]; then
        local npm_size=$(du -sh "${HOME}/.npm" 2>/dev/null | cut -f1)
        echo "  npm cache:           ${npm_size}"
    else
        echo "  npm cache:           0 (cleaned)"
    fi
    
    if [ -d "${HOME}/.cache/huggingface" ]; then
        local hf_size=$(du -sh "${HOME}/.cache/huggingface" 2>/dev/null | cut -f1)
        echo "  Hugging Face cache:  ${hf_size}"
    else
        echo "  Hugging Face cache:  0 (cleaned)"
    fi
    
    if [ -d "/tmp" ]; then
        local tmp_size=$(sudo du -sh /tmp 2>/dev/null | cut -f1)
        echo "  /tmp directory:      ${tmp_size}"
    fi
    
    echo ""
    echo "Cleanup completed successfully!"
}

main() {
    cleanup_apt
    cleanup_conda
    cleanup_pip
    cleanup_npm
    cleanup_huggingface
    cleanup_temp_files
    show_final_disk_usage
}

main "$@"
