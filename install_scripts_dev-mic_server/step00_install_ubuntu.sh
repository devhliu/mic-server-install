#!/usr/bin/env bash
set -euo pipefail

echo "Starting Ubuntu mirror configuration..."

CODENAME=$(lsb_release -sc)
echo "Detected Ubuntu codename: ${CODENAME}"

echo "Configuring PKU mirrors for Ubuntu ${CODENAME}..."

sudo tee /etc/apt/sources.list <<EOF > /dev/null
deb https://mirrors.pku.edu.cn/ubuntu/ ${CODENAME} main restricted universe multiverse
deb https://mirrors.pku.edu.cn/ubuntu/ ${CODENAME}-updates main restricted universe multiverse
deb https://mirrors.pku.edu.cn/ubuntu/ ${CODENAME}-security main restricted universe multiverse
EOF

if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    echo "Removing /etc/apt/sources.list.d/ubuntu.sources to use /etc/apt/sources.list..."
    sudo rm -f /etc/apt/sources.list.d/ubuntu.sources
fi

echo "Updating package lists and upgrading system..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

echo "Ubuntu mirrors configured and system updated successfully."
