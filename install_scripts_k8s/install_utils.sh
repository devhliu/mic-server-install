#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

needs_sudo() {
    local path="$1"
    local expanded_path
    
    expanded_path=$(eval echo "$path")
    
    if [[ "$expanded_path" == "$HOME"* ]] || [[ "$expanded_path" == "~"* ]]; then
        return 1
    fi
    
    local system_paths=("/opt" "/usr" "/usr/local" "/etc" "/var" "/local" "/snap")
    for sys_path in "${system_paths[@]}"; do
        if [[ "$expanded_path" == "$sys_path"* ]]; then
            return 0
        fi
    done
    
    return 0
}

run_cmd() {
    local use_sudo="$1"
    shift
    
    if [ "$use_sudo" = "true" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

get_install_dir() {
    local default_dir="$1"
    echo "${INSTALL_DIR:-$default_dir}"
}

get_profile_file() {
    local install_dir="$1"
    local profile_name="${2:-mic-server}"
    
    if needs_sudo "$install_dir"; then
        echo "/etc/profile.d/${profile_name}.sh"
    else
        local profile_dir="$HOME/.profile.d"
        mkdir -p "$profile_dir"
        echo "$profile_dir/${profile_name}.sh"
    fi
}

insert_text() {
    local search_string="$1"
    local insert_string="$2"
    local filepath="$3"
    local use_sudo="${4:-auto}"
    
    if [ "$use_sudo" = "auto" ]; then
        if needs_sudo "$filepath"; then
            use_sudo="true"
        else
            use_sudo="false"
        fi
    fi
    
    log_info "Checking '$insert_string' in $filepath..."
    
    if [ "$use_sudo" = "true" ]; then
        if ! sudo [ -f "$filepath" ]; then
            log_error "$filepath does not exist!"
            return 1
        fi
        
        if sudo grep -qF "$search_string" "$filepath"; then
            log_warning "SKIPPED: '$insert_string' already exists in $filepath"
            return 0
        else
            log_success "Adding: '$insert_string' to $filepath"
            sudo sh -c "echo '$insert_string' >> '$filepath'"
            return 0
        fi
    else
        if [ ! -f "$filepath" ]; then
            log_error "$filepath does not exist!"
            return 1
        fi
        
        if grep -qF "$search_string" "$filepath"; then
            log_warning "SKIPPED: '$insert_string' already exists in $filepath"
            return 0
        else
            log_success "Adding: '$insert_string' to $filepath"
            echo "$insert_string" >> "$filepath"
            return 0
        fi
    fi
}

check_command() {
    local cmd="$1"
    if command -v "$cmd" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_package() {
    local package="$1"
    local use_sudo="${2:-auto}"
    
    if [ "$use_sudo" = "auto" ]; then
        use_sudo="true"
    fi
    
    log_info "Installing package: $package"
    run_cmd "$use_sudo" apt-get install -y "$package"
}

add_to_path() {
    local path_to_add="$1"
    local profile_file
    
    profile_file=$(get_profile_file "$path_to_add")
    
    if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
        insert_text "$path_to_add" "export PATH=\"\$PATH:$path_to_add\"" "$profile_file"
        export PATH="$PATH:$path_to_add"
        log_success "Added $path_to_add to PATH"
    else
        log_info "$path_to_add already in PATH"
    fi
}

ensure_directory() {
    local dir="$1"
    local use_sudo="${2:-auto}"
    
    if [ "$use_sudo" = "auto" ]; then
        if needs_sudo "$dir"; then
            use_sudo="true"
        else
            use_sudo="false"
        fi
    fi
    
    if [ ! -d "$dir" ]; then
        log_info "Creating directory: $dir"
        run_cmd "$use_sudo" mkdir -p "$dir"
    fi
}

set_ownership() {
    local path="$1"
    local user="${2:-$USER}"
    local group="${3:-$user}"
    
    if [ -d "$path" ] || [ -f "$path" ]; then
        log_info "Setting ownership of $path to $user:$group"
        sudo chown -R "$user:$group" "$path"
    fi
}

download_file() {
    local url="$1"
    local output_path="$2"
    local use_sudo="${3:-auto}"
    
    if [ "$use_sudo" = "auto" ]; then
        if needs_sudo "$output_path"; then
            use_sudo="true"
        else
            use_sudo="false"
        fi
    fi
    
    log_info "Downloading $url to $output_path"
    
    if [ "$use_sudo" = "true" ]; then
        sudo curl -fsSL "$url" -o "$output_path"
    else
        curl -fsSL "$url" -o "$output_path"
    fi
}

make_executable() {
    local file="$1"
    local use_sudo="${2:-auto}"
    
    if [ "$use_sudo" = "auto" ]; then
        if needs_sudo "$file"; then
            use_sudo="true"
        else
            use_sudo="false"
        fi
    fi
    
    log_info "Making $file executable"
    run_cmd "$use_sudo" chmod +x "$file"
}
