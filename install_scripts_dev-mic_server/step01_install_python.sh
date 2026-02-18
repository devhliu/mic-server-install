#!/usr/bin/env bash
set -euo pipefail

miniconda_url="https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-py312_25.9.1-3-Linux-x86_64.sh"
install_dir="/opt/miniconda3"
tmp_installer="/tmp/miniconda3-installer.sh"
profile_d_file="/etc/profile.d/miniconda.sh"

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

  sudo bash "${tmp_installer}" -b -p "${install_dir}"
  rm -f "${tmp_installer}"
fi

sudo install -d -m 0777 "${install_dir}"
sudo chown -R root:root "${install_dir}"
sudo chmod -R a+rwX "${install_dir}"

sudo tee "${profile_d_file}" > /dev/null <<'EOF'
export PATH="/opt/miniconda3/bin:${PATH}"
EOF

sudo chmod 0644 "${profile_d_file}"

pip_config_file="/etc/pip.conf"
echo "Configuring pip mirror..."
sudo tee "${pip_config_file}" > /dev/null <<EOF
[global]
index-url = https://pypi.mirrors.pku.edu.cn/simple
trusted-host = pypi.mirrors.pku.edu.cn
EOF
sudo chmod 0644 "${pip_config_file}"

echo "Configuring conda mirror..."
sudo "${install_dir}/bin/conda" config --system --add channels https://mirrors.pku.edu.cn/anaconda/pkgs/free/
sudo "${install_dir}/bin/conda" config --system --add channels https://mirrors.pku.edu.cn/anaconda/pkgs/main/
sudo "${install_dir}/bin/conda" config --system --set show_channel_urls yes

echo "Miniconda installed, PATH configured, and mirrors set for all users."
