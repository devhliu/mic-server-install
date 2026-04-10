#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

echo "Starting Ubuntu mirror configuration..."
echo "Note: System configuration always requires sudo."

USE_SUDO="true"

CODENAME=$(lsb_release -sc)
echo "Detected Ubuntu codename: ${CODENAME}"

echo "Configuring PKU mirrors for Ubuntu ${CODENAME}..."

run_cmd "$USE_SUDO" tee /etc/apt/sources.list <<EOF > /dev/null
deb https://mirrors.pku.edu.cn/ubuntu/ ${CODENAME} main restricted universe multiverse
deb https://mirrors.pku.edu.cn/ubuntu/ ${CODENAME}-updates main restricted universe multiverse
deb https://mirrors.pku.edu.cn/ubuntu/ ${CODENAME}-security main restricted universe multiverse
EOF

if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    echo "Removing /etc/apt/sources.list.d/ubuntu.sources to use /etc/apt/sources.list..."
    run_cmd "$USE_SUDO" rm -f /etc/apt/sources.list.d/ubuntu.sources
fi

echo "Updating package lists and upgrading system..."
run_cmd "$USE_SUDO" apt-get update
run_cmd "$USE_SUDO" apt-get upgrade -y
run_cmd "$USE_SUDO" apt-get autoremove -y

echo "Ubuntu mirrors configured and system updated successfully."
