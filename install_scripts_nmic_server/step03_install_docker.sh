#!/bin/bash

# Exit on error
set -e

echo "Starting Docker and Docker Compose installation for Ubuntu 24.04..."

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

echo "Downloading Docker GPG key..."
# Using Aliyun mirror for faster access in China
sudo curl -fsSL --retry 5 --retry-delay 2 --connect-timeout 10 https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Check if the file was actually downloaded and is not empty
if [ ! -s /etc/apt/keyrings/docker.asc ]; then
    echo "Error: Failed to download Docker GPG key from Aliyun mirror."
    exit 1
fi

sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker Engine, CLI, containerd, and Docker Compose plugin
echo "Installing Docker packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker Hub mirrors
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

# Install NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
# Add the package repositories (using USTC mirror for China)
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

# Verify installation
echo "Verifying installation..."
docker_version=$(docker --version)
compose_version=$(docker compose version)
nvidia_ctk_version=$(nvidia-ctk --version)

# Add current user to docker group
echo "Adding current user ($USER) to the docker group..."
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock

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
echo "Activating docker group..."
# Switch to the new group immediately
newgrp docker
