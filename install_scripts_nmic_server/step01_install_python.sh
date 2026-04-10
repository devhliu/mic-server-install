#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

miniconda_url="https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-py312_25.9.1-3-Linux-x86_64.sh"
install_dir=$(get_install_dir "/opt/miniconda3")
tmp_installer="/tmp/miniconda3-installer.sh"

USE_SUDO="false"
if needs_sudo "$install_dir"; then
  USE_SUDO="true"
  echo "Installation directory ${install_dir} requires sudo."
else
  echo "Installation directory ${install_dir} does not require sudo."
fi

profile_d_file=$(get_profile_file "$install_dir" "miniconda.sh")

if [ -d "${install_dir}" ]; then
  echo "Miniconda already installed at ${install_dir}."
else
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${miniconda_url}" -o "${tmp_installer}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${tmp_installer}" "${miniconda_url}"
  else
    echo "Neither curl nor wget is available."
    exit 1
  fi

  run_cmd "$USE_SUDO" bash "${tmp_installer}" -b -p "${install_dir}"
  rm -f "${tmp_installer}"
fi

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
  pip_config_file="/etc/pip.conf"
else
  pip_config_file="${HOME}/.pip/pip.conf"
fi
echo "Configuring pip mirror at ${pip_config_file}..."

pip_dir=$(dirname "${pip_config_file}")
run_cmd "$USE_SUDO" mkdir -p "${pip_dir}"

run_cmd "$USE_SUDO" tee "${pip_config_file}" > /dev/null <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
run_cmd "$USE_SUDO" chmod 0644 "${pip_config_file}"

echo "Configuring conda mirror..."
if [ "$USE_SUDO" = "true" ]; then
  run_cmd "$USE_SUDO" "${install_dir}/bin/conda" config --system --add channels https://mirrors.pku.edu.cn/anaconda/pkgs/free/
  run_cmd "$USE_SUDO" "${install_dir}/bin/conda" config --system --add channels https://mirrors.pku.edu.cn/anaconda/pkgs/main/
  run_cmd "$USE_SUDO" "${install_dir}/bin/conda" config --system --set show_channel_urls yes
else
  "${install_dir}/bin/conda" config --system --add channels https://mirrors.pku.edu.cn/anaconda/pkgs/free/
  "${install_dir}/bin/conda" config --system --add channels https://mirrors.pku.edu.cn/anaconda/pkgs/main/
  "${install_dir}/bin/conda" config --system --set show_channel_urls yes
fi

echo "Miniconda installed, PATH configured, and mirrors set."
if [ "$USE_SUDO" = "true" ]; then
  echo "Configuration is system-wide for all users."
else
  echo "Configuration is user-specific for ${HOME}."
fi
