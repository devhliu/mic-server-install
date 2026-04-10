#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

node_version="v22.20.0"
node_dist="node-${node_version}-linux-x64"
node_url="https://nodejs.org/dist/${node_version}/${node_dist}.tar.xz"
install_dir=$(get_install_dir "/opt/node/${node_version}")
download_dir="/tmp"
tmp_archive="${download_dir}/${node_dist}.tar.xz"
tmp_extract_dir="/tmp/${node_dist}"

USE_SUDO="false"
if needs_sudo "$install_dir"; then
  USE_SUDO="true"
  echo "Installation directory ${install_dir} requires sudo."
else
  echo "Installation directory ${install_dir} does not require sudo."
fi

profile_d_file=$(get_profile_file "$install_dir" "node-${node_version}.sh")

usage() {
  echo "Usage: $0 {download|install}"
  echo "  download - Download Node.js archive to /tmp"
  echo "  install  - Install Node.js from downloaded archive"
  echo ""
  echo "Environment Variables:"
  echo "  INSTALL_DIR - Custom installation directory (default: /opt/node/${node_version})"
  exit 1
}

download_node() {
  echo "Downloading Node.js ${node_version}..."
  
  run_cmd "$USE_SUDO" install -d -m 0755 "${download_dir}"
  
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${node_url}" -o "${tmp_archive}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${tmp_archive}" "${node_url}"
  else
    echo "Neither curl nor wget is available."
    exit 1
  fi
  
  echo "Node.js ${node_version} downloaded to ${tmp_archive}"
}

install_node() {
  if [ ! -f "${tmp_archive}" ]; then
    echo "Error: Archive not found at ${tmp_archive}"
    echo "Run '$0 download' first."
    exit 1
  fi
  
  echo "Installing Node.js ${node_version} to ${install_dir}..."
  
  run_cmd "$USE_SUDO" rm -rf "${tmp_extract_dir}"
  run_cmd "$USE_SUDO" tar -xJf "${tmp_archive}" -C /tmp
  
  run_cmd "$USE_SUDO" rm -rf "${install_dir}"
  run_cmd "$USE_SUDO" mkdir -p "$(dirname "${install_dir}")"
  run_cmd "$USE_SUDO" mv "${tmp_extract_dir}" "${install_dir}"
  
  rm -f "${tmp_archive}"
  
  run_cmd "$USE_SUDO" install -d -m 0777 "${install_dir}"
  if [ "$USE_SUDO" = "true" ]; then
    run_cmd "$USE_SUDO" chown -R root:root "${install_dir}"
  else
    run_cmd "$USE_SUDO" chown -R "$(whoami):$(id -gn)" "${install_dir}"
  fi
  run_cmd "$USE_SUDO" chmod -R a+rwX "${install_dir}"
  
  profile_dir=$(dirname "${profile_d_file}")
  run_cmd "$USE_SUDO" mkdir -p "${profile_dir}"
  
  run_cmd "$USE_SUDO" tee "${profile_d_file}" > /dev/null <<EOF
export PATH="${install_dir}/bin:\${PATH}"
EOF
  
  run_cmd "$USE_SUDO" chmod 0644 "${profile_d_file}"
  
  echo "Configuring npm mirror..."
  if [ "$USE_SUDO" = "true" ]; then
    run_cmd "$USE_SUDO" "${install_dir}/bin/npm" config set registry https://registry.npmmirror.com/ --global
  else
    "${install_dir}/bin/npm" config set registry https://registry.npmmirror.com/ --global
  fi
  
  echo "Node ${node_version} installed, PATH configured, and npm mirror set."
  if [ "$USE_SUDO" = "true" ]; then
    echo "Configuration is system-wide for all users."
  else
    echo "Configuration is user-specific for ${HOME}."
  fi
}

case "${1:-}" in
  download)
    download_node
    ;;
  install)
    install_node
    ;;
  *)
    usage
    ;;
esac
