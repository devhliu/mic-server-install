#!/bin/bash

set -e

echo "Starting Docker and Docker Compose installation for Ubuntu 24.04..."

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

echo "Downloading Docker GPG key..."
sudo curl -fsSL --retry 5 --retry-delay 2 --connect-timeout 10 https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

if [ ! -s /etc/apt/keyrings/docker.asc ]; then
    echo "Error: Failed to download Docker GPG key from Aliyun mirror."
    exit 1
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

echo "Installing Docker packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Configuring Docker Hub mirrors..."
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
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

sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Verifying installation..."
docker_version=$(docker --version)
compose_version=$(docker compose version)

echo "Adding current user ($USER) to the docker group..."
sudo usermod -aG docker $USER

echo "Success! Installed versions:"
echo "- $docker_version"
echo "- $compose_version"
echo ""

remove_dirty_images() {
    echo "Checking for dirty (dangling) docker images..."
    dirty_images=$(docker images --filter "dangling=true" -q)
    if [ -n "$dirty_images" ]; then
        echo "Found dirty images, removing them..."
        docker rmi $(docker images | grep "^<none>" | awk "{print \$3}") 2>/dev/null || true
        docker image prune -f
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
