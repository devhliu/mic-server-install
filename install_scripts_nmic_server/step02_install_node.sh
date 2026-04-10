#!/usr/bin/env bash
# step02_install_node.sh - Install Node.js
# Usage: bash step02_install_node.sh [all|download|install]
#   all      - Download and install (default)
#   download - Only download archive to /tmp
#   install  - Install; auto-downloads if missing
# Environment Variables:
#   INSTALL_DIR - Custom installation directory (default: /opt/node/<version>)
# Installs to INSTALL_DIR or /opt/node/<version>, links node/npm/npx into /usr/local/bin or ~/.local/bin,
# sets PATH via /etc/profile.d or ~/.profile.d, and configures npm registry mirror.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

node_version="v22.20.0"
npm_version="11.11.0"
node_dist="node-${node_version}-linux-x64"
node_mirrors=(
  "https://npmmirror.com/mirrors/node"
  "https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"
  "https://nodejs.org/dist"
)
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
  echo "Usage: $0 [all|download|install]"
  echo "  all      - Download and install Node.js (default)"
  echo "  download - Download Node.js archive to /tmp"
  echo "  install  - Install Node.js (downloads if missing)"
  echo ""
  echo "Environment Variables:"
  echo "  INSTALL_DIR - Custom installation directory (default: /opt/node/${node_version})"
  exit 1
}

download_node() {
  echo "Downloading Node.js ${node_version}..."
  
  run_cmd "$USE_SUDO" install -d -m 0755 "${download_dir}"
  
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
  
  if [ "$USE_SUDO" = "true" ]; then
    echo "Linking node, npm, npx into /usr/local/bin..."
    run_cmd "$USE_SUDO" install -d -m 0755 /usr/local/bin
    run_cmd "$USE_SUDO" ln -sf "${install_dir}/bin/node" /usr/local/bin/node
    run_cmd "$USE_SUDO" ln -sf "${install_dir}/bin/npm" /usr/local/bin/npm
    run_cmd "$USE_SUDO" ln -sf "${install_dir}/bin/npx" /usr/local/bin/npx
  else
    local local_bin="${HOME}/.local/bin"
    echo "Linking node, npm, npx into ${local_bin}..."
    mkdir -p "${local_bin}"
    ln -sf "${install_dir}/bin/node" "${local_bin}/node"
    ln -sf "${install_dir}/bin/npm" "${local_bin}/npm"
    ln -sf "${install_dir}/bin/npx" "${local_bin}/npx"
  fi
  
  echo "Configuring npm mirror..."
  if [ "$USE_SUDO" = "true" ]; then
    run_cmd "$USE_SUDO" env PATH="${install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
      "${install_dir}/bin/node" \
      "${install_dir}/lib/node_modules/npm/bin/npm-cli.js" \
      config set registry https://registry.npmmirror.com/ --global

    echo "Updating npm to ${npm_version}..."
    run_cmd "$USE_SUDO" env PATH="${install_dir}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
      "${install_dir}/bin/node" \
      "${install_dir}/lib/node_modules/npm/bin/npm-cli.js" \
      install -g "npm@${npm_version}"
  else
    env PATH="${install_dir}/bin:${PATH}" \
      "${install_dir}/bin/node" \
      "${install_dir}/lib/node_modules/npm/bin/npm-cli.js" \
      config set registry https://registry.npmmirror.com/ --global

    echo "Updating npm to ${npm_version}..."
    env PATH="${install_dir}/bin:${PATH}" \
      "${install_dir}/bin/node" \
      "${install_dir}/lib/node_modules/npm/bin/npm-cli.js" \
      install -g "npm@${npm_version}"
  fi

  echo "Verifying node, npm, and npx availability..."
  if command -v node >/dev/null 2>&1; then node -v; fi
  if command -v npm  >/dev/null 2>&1; then npm -v; fi
  if command -v npx  >/dev/null 2>&1; then npx -v; fi
  
  if [ "$USE_SUDO" = "true" ] && [ -n "${SUDO_USER-}" ] && id "${SUDO_USER}" >/dev/null 2>&1; then
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
  
  echo "Node ${node_version} installed, PATH configured, and npm mirror set."
  if [ "$USE_SUDO" = "true" ]; then
    echo "Configuration is system-wide for all users."
  else
    echo "Configuration is user-specific for ${HOME}."
  fi
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
