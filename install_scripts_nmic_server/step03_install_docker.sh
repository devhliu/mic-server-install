#!/bin/bash

# Exit on error
set -e

echo "Starting Docker and Docker Compose installation for Ubuntu 24.04..."

if [ ! -d /tmp ]; then sudo mkdir -p /tmp; fi
sudo chmod 1777 /tmp

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings

echo "Downloading Docker GPG key with fallbacks..."
DOCKER_GPG_TARGET=/etc/apt/keyrings/docker.asc
TMP_GPG=/tmp/docker.gpg.tmp
rm -f "$TMP_GPG"
GPG_URLS=(
  "https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg"
  "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg"
  "https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg"
  "https://download.docker.com/linux/ubuntu/gpg"
)
for u in "${GPG_URLS[@]}"; do
  if sudo curl -fsSL --retry 5 --retry-delay 2 --connect-timeout 8 "$u" -o "$TMP_GPG"; then
    if [ -s "$TMP_GPG" ]; then
      sudo mv "$TMP_GPG" "$DOCKER_GPG_TARGET"
      break
    fi
  fi
done

if [ ! -s /etc/apt/keyrings/docker.asc ]; then
  echo "Error: Failed to download Docker GPG key from all mirrors."
  exit 1
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
ARCH=$(dpkg --print-architecture)
REPO_BASES=(
  "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu"
  "https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu"
  "https://mirrors.aliyun.com/docker-ce/linux/ubuntu"
  "https://download.docker.com/linux/ubuntu"
)
SELECTED_BASE=""
for base in "${REPO_BASES[@]}"; do
  if curl -fsS --connect-timeout 5 -I "$base/dists/$CODENAME/InRelease" >/dev/null; then
    SELECTED_BASE="$base"
    break
  fi
done
if [ -z "$SELECTED_BASE" ]; then
  SELECTED_BASE="https://download.docker.com/linux/ubuntu"
fi
echo "Using Docker APT repo: $SELECTED_BASE"
sudo rm -f /etc/apt/sources.list.d/docker.list
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] $SELECTED_BASE $CODENAME stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

echo "Installing Docker packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Enabling and starting Docker services on boot..."
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now docker.service
  sudo systemctl enable --now containerd.service
fi

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

echo "Installing NVIDIA Container Toolkit..."
curl -fsSL https://mirrors.ustc.edu.cn/libnvidia-container/gpgkey | sudo gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://mirrors.ustc.edu.cn/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://nvidia.github.io#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://mirrors.ustc.edu.cn#g' | \
    sed "s#\$(ARCH)#$(dpkg --print-architecture)#g" | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Install the package
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configure the container runtime
echo "Configuring NVIDIA container runtime..."
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker to apply changes
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Verifying installation..."
docker_version=$(docker --version)
compose_version=$(docker compose version)
nvidia_ctk_version=$(nvidia-ctk --version)

TARGET_USER="${SUDO_USER:-$USER}"
echo "Adding user ($TARGET_USER) to the docker group..."
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi
sudo usermod -aG docker "$TARGET_USER"

echo "Success! Installed versions:"
echo "- $docker_version"
echo "- $compose_version"
echo "- $nvidia_ctk_version"
echo ""

# Function to remove dirty (dangling) docker images
remove_dirty_images() {
    echo "Checking for dirty (dangling) docker images..."
    # Using sudo to ensure permissions before group update takes effect
    dirty_images=$(sudo docker images --filter "dangling=true" -q)
    if [ -n "$dirty_images" ]; then
        echo "Found dirty images, removing them..."
        sudo docker rmi $(sudo docker images | grep "^<none>" | awk "{print \$3}") 2>/dev/null || true
        sudo docker image prune -f
        echo "Dirty images removed."
    else
        echo "No dirty images found."
    fi
}

# Ask user if they want to remove dirty images
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

# Function to install docker experimental features
install_docker_experimental_features() {
    echo "Installing Docker experimental features..."
    
    # 1. docker model install
    echo "Executing: docker model install"
    if sudo docker model install; then
         echo "Successfully ran 'docker model install'"
         
         # 2. docker model backend install vllm
         echo "Executing: docker model backend install vllm"
         if sudo docker model backend install vllm; then
              echo "Successfully ran 'docker model backend install vllm'"
         else
              echo "Error running 'docker model backend install vllm'"
         fi
    else
         echo "Error running 'docker model install'. Skipping backend installation."
    fi
}

# Ask user if they want to install experimental features
read -p "Do you want to install Docker experimental features (docker model, vllm)? [y/N]: " experimental_choice
case "$experimental_choice" in
    y|Y|yes|YES)
        install_docker_experimental_features
        ;;
    *)
        echo "Skipping Docker experimental features installation."
        ;;
esac

echo ""
echo "Next steps:"
echo "- To use Docker without sudo, open a new session (log out/in) or run: newgrp docker"
echo "- Verify Docker works and is connected to the daemon:"
echo "  docker info"
