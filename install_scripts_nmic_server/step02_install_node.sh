#!/usr/bin/env bash
# step02_install_node.sh - Install Node.js system-wide
# Usage: sudo bash step02_install_node.sh [all|download|install]
#   all      - Download and install (default)
#   download - Only download archive to /tmp
#   install  - Install; auto-downloads if missing
# Installs to /opt/node/<version>, links node/npm/npx into /usr/local/bin,
# sets PATH via /etc/profile.d, and configures npm registry mirror.
set -euo pipefail

node_version="v22.20.0"
npm_version="11.11.0"
node_dist="node-${node_version}-linux-x64"
node_mirrors=(
  "https://npmmirror.com/mirrors/node"
  "https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"
  "https://nodejs.org/dist"
)
install_dir="/opt/node/${node_version}"
download_dir="/tmp"
tmp_archive="${download_dir}/${node_dist}.tar.xz"
tmp_extract_dir="/tmp/${node_dist}"
profile_d_file="/etc/profile.d/node-${node_version}.sh"

usage() {
  echo "Usage: $0 [all|download|install]"
  echo "  all      - Download and install Node.js (default)"
  echo "  download - Download Node.js archive to /tmp"
  echo "  install  - Install Node.js (downloads if missing)"
  exit 1
}

download_node() {
  echo "Downloading Node.js ${node_version}..."
  
  sudo install -d -m 0755 "${download_dir}"
  
  local node_file="${node_dist}.tar.xz"
  local downloaded=false
  
  for mirror in "${node_mirrors[@]}"; do
    local node_url="${mirror}/${node_version}/${node_file}"
    echo "Trying mirror: ${mirror}"
    
    if command -v curl >/dev/null 2>&1; then
      if curl -fsSL --connect-timeout 10 "${node_url}" -o "${tmp_archive}" 2>/dev/null; then
        if [ -s "${tmp_archive}" ]; then
          downloaded=true
          echo "Downloaded from: ${mirror}"
          break
        fi
      fi
    elif command -v wget >/dev/null 2>&1; then
      if wget -q --timeout=10 -O "${tmp_archive}" "${node_url}" 2>/dev/null; then
        if [ -s "${tmp_archive}" ]; then
          downloaded=true
          echo "Downloaded from: ${mirror}"
          break
        fi
      fi
    fi
    
    rm -f "${tmp_archive}"
  done
  
  if [ "$downloaded" = false ]; then
    echo "Error: Failed to download Node.js from all mirrors."
    exit 1
  fi
  
  echo "Node.js ${node_version} downloaded to ${tmp_archive}"
}

install_node() {
  if [ ! -f "${tmp_archive}" ]; then
    download_node
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
  
  echo "Linking node, npm, npx into /usr/local/bin..."
  sudo install -d -m 0755 /usr/local/bin
  sudo ln -sf "${install_dir}/bin/node" /usr/local/bin/node
  sudo ln -sf "${install_dir}/bin/npm" /usr/local/bin/npm
  sudo ln -sf "${install_dir}/bin/npx" /usr/local/bin/npx
  
  # Configure npm mirror
  echo "Configuring npm mirror..."
  sudo env PATH="${install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    "${install_dir}/bin/node" \
    "${install_dir}/lib/node_modules/npm/bin/npm-cli.js" \
    config set registry https://registry.npmmirror.com/ --global

  echo "Updating npm to ${npm_version}..."
  sudo env PATH="${install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    "${install_dir}/bin/node" \
    "${install_dir}/lib/node_modules/npm/bin/npm-cli.js" \
    install -g "npm@${npm_version}"

  echo "Verifying node, npm, and npx availability..."
  if command -v node >/dev/null 2>&1; then node -v; fi
  if command -v npm  >/dev/null 2>&1; then npm -v; fi
  if command -v npx  >/dev/null 2>&1; then npx -v; fi
  
  if [ -n "${SUDO_USER-}" ] && id "${SUDO_USER}" >/dev/null 2>&1; then
    echo "Verifying availability for user '${SUDO_USER}'..."
    if su - "${SUDO_USER}" -c 'command -v node >/dev/null 2>&1'; then
      su - "${SUDO_USER}" -c 'node -v'
    else
      echo "Warning: node not found for ${SUDO_USER}. Ensure /usr/local/bin is in PATH."
    fi
    if su - "${SUDO_USER}" -c 'command -v npm >/dev/null 2>&1'; then
      su - "${SUDO_USER}" -c 'npm -v'
    else
      echo "Warning: npm not found for ${SUDO_USER}. Ensure /usr/local/bin is in PATH."
    fi
    if su - "${SUDO_USER}" -c 'command -v npx >/dev/null 2>&1'; then
      su - "${SUDO_USER}" -c 'npx -v'
    else
      echo "Warning: npx not found for ${SUDO_USER}. Ensure /usr/local/bin is in PATH."
    fi
  fi
  
  echo "Node ${node_version} installed, PATH configured, and npm mirror set for all users."
}

case "${1:-}" in
  all|"")
    download_node
    install_node
    ;;
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
