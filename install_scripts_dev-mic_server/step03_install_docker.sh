#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

echo "Starting Docker and Docker Compose installation for Ubuntu 24.04..."
echo "Note: Docker is a system-level service and always requires sudo for installation."

USE_SUDO="true"

run_cmd "$USE_SUDO" apt-get update
run_cmd "$USE_SUDO" apt-get install -y ca-certificates curl
run_cmd "$USE_SUDO" install -m 0755 -d /etc/apt/keyrings

echo "Downloading Docker GPG key..."
run_cmd "$USE_SUDO" curl -fsSL --retry 5 --retry-delay 2 --connect-timeout 10 https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

if [ ! -s /etc/apt/keyrings/docker.asc ]; then
    echo "Error: Failed to download Docker GPG key from Aliyun mirror."
    exit 1
fi

run_cmd "$USE_SUDO" chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  run_cmd "$USE_SUDO" tee /etc/apt/sources.list.d/docker.list > /dev/null
run_cmd "$USE_SUDO" apt-get update

echo "Installing Docker packages..."
run_cmd "$USE_SUDO" apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Configuring Docker Hub mirrors..."
run_cmd "$USE_SUDO" mkdir -p /etc/docker
cat <<EOF | run_cmd "$USE_SUDO" tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://registry.docker-cn.com",
    "https://dockerhub.azk8s.cn",
    "https://mirror.ccs.tencentyun.com",
    "https://registry.dockermirror.com",
    "https://mirror.baidubce.com",
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.nju.edu.cn"
  ]
}
EOF

run_cmd "$USE_SUDO" systemctl daemon-reload
run_cmd "$USE_SUDO" systemctl restart docker

echo "Verifying installation..."
docker_version=$(docker --version)
compose_version=$(docker compose version)

TARGET_USER="${SUDO_USER:-$USER}"
echo "Adding user ($TARGET_USER) to the docker group..."
run_cmd "$USE_SUDO" usermod -aG docker "$TARGET_USER"

echo "Success! Installed versions:"
echo "- $docker_version"
echo "- $compose_version"
echo ""

remove_dirty_images() {
    echo "Checking for dirty (dangling) docker images..."
    dirty_images=$(run_cmd "$USE_SUDO" docker images --filter "dangling=true" -q)
    if [ -n "$dirty_images" ]; then
        echo "Found dirty images, removing them..."
        run_cmd "$USE_SUDO" docker rmi $(run_cmd "$USE_SUDO" docker images | grep "^<none>" | awk "{print \$3}") 2>/dev/null || true
        run_cmd "$USE_SUDO" docker image prune -f
        echo "Dirty images removed."
    else
        echo "No dirty images found."
    fi
}

read -p "Do you want to remove dirty (dangling) docker images? [y/N]: " remove_choice
case "$remove_choice" in
    y|Y|yes|YES)
        remove_dirty_images
        ;;
    *)
        echo "Skipping dirty image removal."
        ;;
esac

echo ""
echo "NOTE: To apply the docker group changes, please log out and log back in,"
echo "or run the following command in your current session:"
echo "newgrp docker"
