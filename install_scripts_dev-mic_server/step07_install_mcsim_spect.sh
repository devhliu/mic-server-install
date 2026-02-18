#!/usr/bin/env bash
set -euo pipefail

simind_install_dir="/opt/simind"
profile_d_file="/etc/profile.d/simind.sh"
simind_executable="simind"

usage() {
  echo "Usage: $0 <local_package_path>"
  echo "  <local_package_path> - Path to the SIMIND installation package"
  echo ""
  echo "This script installs SIMIND (Monte Carlo SPECT simulation program)"
  echo "to system level for all users on Ubuntu 24.04."
  exit 1
}

validate_input() {
  local package_path="$1"

  if [ -z "${package_path}" ]; then
    echo "Error: No package path provided."
    usage
  fi

  if [ ! -f "${package_path}" ]; then
    echo "Error: Package file not found: ${package_path}"
    exit 1
  fi

  if [ ! -r "${package_path}" ]; then
    echo "Error: Package file is not readable: ${package_path}"
    exit 1
  fi

  echo "Package validated: ${package_path}"
}

extract_package() {
  local package_path="$1"
  local tmp_extract_dir="/tmp/simind_extract_$$"

  echo "Extracting SIMIND package..." >&2

  sudo rm -rf "${tmp_extract_dir}"
  sudo mkdir -p "${tmp_extract_dir}"

  case "${package_path}" in
    *.tar.gz|*.tgz)
      sudo tar -xzf "${package_path}" -C "${tmp_extract_dir}"
      ;;
    *.tar.xz)
      sudo tar -xJf "${package_path}" -C "${tmp_extract_dir}"
      ;;
    *.tar.bz2|*.tbz2)
      sudo tar -xjf "${package_path}" -C "${tmp_extract_dir}"
      ;;
    *.zip)
      if command -v unzip >/dev/null 2>&1; then
        sudo unzip -q "${package_path}" -d "${tmp_extract_dir}"
      else
        echo "Error: unzip is not installed. Install with: sudo apt-get install unzip" >&2
        exit 1
      fi
      ;;
    *)
      echo "Error: Unsupported package format. Supported formats: .tar.gz, .tar.xz, .tar.bz2, .zip" >&2
      exit 1
      ;;
  esac

  echo "${tmp_extract_dir}"
}

install_simind() {
  local package_path="$1"
  local tmp_extract_dir

  validate_input "${package_path}"
  tmp_extract_dir=$(extract_package "${package_path}")

  echo "Installing SIMIND to ${simind_install_dir}..."

  sudo rm -rf "${simind_install_dir}"
  sudo mkdir -p "$(dirname "${simind_install_dir}")"

  sudo mv "${tmp_extract_dir}"/* "${simind_install_dir}" 2>/dev/null || \
  sudo mv "${tmp_extract_dir}" "${simind_install_dir}"

  sudo rm -rf "${tmp_extract_dir}"

  sudo chown -R root:root "${simind_install_dir}"
  sudo chmod -R 755 "${simind_install_dir}"
  sudo find "${simind_install_dir}" -type d -exec chmod 755 {} \;
  sudo find "${simind_install_dir}" -type f -exec chmod 644 {} \;

  set_executable_permissions
  create_symlink
  configure_environment
  verify_installation
}

set_executable_permissions() {
  echo "Setting executable permissions for all users..."

  if [ -d "${simind_install_dir}/bin" ]; then
    sudo find "${simind_install_dir}/bin" -type f -exec chmod a+rx {} \;
  fi

  sudo find "${simind_install_dir}" -maxdepth 1 -type f \( -name "simind*" -o -name "*.exe" \) -exec chmod a+rx {} \;

  echo "Executable permissions set for all users."
}

create_symlink() {
  local main_exec=""

  for exec_path in "${simind_install_dir}/bin/simind" \
                    "${simind_install_dir}/simind" \
                    "${simind_install_dir}/simind.exe"; do
    if [ -f "${exec_path}" ]; then
      main_exec="${exec_path}"
      break
    fi
  done

  if [ -n "${main_exec}" ]; then
    echo "Creating system-wide symlink for SIMIND..."
    sudo ln -sf "${main_exec}" "/usr/local/bin/simind"
    echo "Symlink created: /usr/local/bin/simind -> ${main_exec}"
  else
    echo "Warning: Could not find main SIMIND executable for symlink."
    echo "Users will need to use full path or add SIMIND to PATH manually."
  fi
}

configure_environment() {
  echo "Configuring environment variables for all users..."

  sudo tee "${profile_d_file}" > /dev/null <<'EOF'
export SMC_DIR="/opt/simind/"
export PATH="${SMC_DIR%/}/bin:${SMC_DIR%/}:${PATH}"
EOF
  sudo chmod 0644 "${profile_d_file}"

  local bashrc_file="/etc/bash.bashrc"
  local env_marker="# SIMIND environment configuration"

  if ! sudo grep -q "${env_marker}" "${bashrc_file}" 2>/dev/null; then
    echo "Adding SIMIND to system-wide bashrc for auto-activation..."
    sudo tee -a "${bashrc_file}" > /dev/null <<'EOF'

# SIMIND environment configuration
export SMC_DIR="/opt/simind/"
export PATH="${SMC_DIR%/}/bin:${SMC_DIR%/}:${PATH}"
EOF
    echo "Auto-activation configured in ${bashrc_file}"
  else
    echo "SIMIND already configured in ${bashrc_file}"
  fi

  echo "Environment configured for all users (login and interactive shells)"
  echo "SMC_DIR set to: ${simind_install_dir}/"
}

verify_installation() {
  echo ""
  echo "Verifying installation for all users..."

  if [ -f "/usr/local/bin/simind" ]; then
    echo "✓ Symlink created: /usr/local/bin/simind"
  else
    echo "✗ Warning: Symlink not created"
  fi

  if [ -f "${profile_d_file}" ]; then
    echo "✓ Environment file created: ${profile_d_file}"
  else
    echo "✗ Warning: Environment file not created"
  fi

  if sudo grep -q "SIMIND environment configuration" "/etc/bash.bashrc" 2>/dev/null; then
    echo "✓ Auto-activation configured in /etc/bash.bashrc"
  else
    echo "✗ Warning: Auto-activation not configured"
  fi

  if [ -d "${simind_install_dir}" ]; then
    echo "✓ Installation directory: ${simind_install_dir}"
  else
    echo "✗ Warning: Installation directory not found"
  fi

  echo ""
  echo "Installation complete!"
  echo "SIMIND is now automatically available for all users."
  echo "SMC_DIR environment variable is set with trailing slash."
  echo "Open a new terminal or run: exec bash"
  echo "Then simply run: simind"
}

if [ "$#" -ne 1 ]; then
  usage
fi

install_simind "$1"
