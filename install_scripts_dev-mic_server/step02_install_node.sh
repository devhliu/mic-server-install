#!/usr/bin/env bash
set -euo pipefail

node_version="v22.20.0"
node_dist="node-${node_version}-linux-x64"
node_url="https://nodejs.org/dist/${node_version}/${node_dist}.tar.xz"
install_dir="/opt/node/${node_version}"
download_dir="/tmp"
tmp_archive="${download_dir}/${node_dist}.tar.xz"
tmp_extract_dir="/tmp/${node_dist}"
profile_d_file="/etc/profile.d/node-${node_version}.sh"

usage() {
  echo "Usage: $0 {download|install}"
  echo "  download - Download Node.js archive to /tmp"
  echo "  install  - Install Node.js from downloaded archive to /opt"
  exit 1
}

download_node() {
  echo "Downloading Node.js ${node_version}..."
  
  sudo install -d -m 0755 "${download_dir}"
  
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
  
  sudo rm -rf "${tmp_extract_dir}"
  sudo tar -xJf "${tmp_archive}" -C /tmp
  
  sudo rm -rf "${install_dir}"
  sudo mkdir -p "$(dirname "${install_dir}")"
  sudo mv "${tmp_extract_dir}" "${install_dir}"
  
  rm -f "${tmp_archive}"
  
  sudo install -d -m 0777 "${install_dir}"
  sudo chown -R root:root "${install_dir}"
  sudo chmod -R a+rwX "${install_dir}"
  
  sudo tee "${profile_d_file}" > /dev/null <<EOF
export PATH="${install_dir}/bin:\${PATH}"
EOF
  
  sudo chmod 0644 "${profile_d_file}"
  
  echo "Configuring npm mirror..."
  sudo "${install_dir}/bin/npm" config set registry https://registry.npmmirror.com/ --global
  
  echo "Node ${node_version} installed, PATH configured, and npm mirror set for all users."
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
