#!/bin/bash

#------------------------------------------------------------------------------------
#
# version
# updated @ 2025-03-01
#
#------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------
#
# install docker
#
#------------------------------------------------------------------------------------

# install intructions:
# https://docs.docker.com/engine/install/ubuntu/

# remove old installations of docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# sudo apt-get remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

# remove docker enginne - https://docs.docker.com/engine/install/ubuntu/#uninstall-docker-engine
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

#--------------------------------------------------------------------------------------------------------------------------------#
## 1.1 Install using the apt repository
#--------------------------------------------------------------------------------------------------------------------------------#

# # install dependencies
# sudo apt-get update
# sudo apt-get install ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc

# # Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update

# # install docker engine
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#--------------------------------------------------------------------------------------------------------------------------------#
## 1.2 Install using the apt repository @ Ubuntu 24.04 LTS (noble)
#--------------------------------------------------------------------------------------------------------------------------------#
DOCKER_DOWNLOAD_URLS="https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64"
DOCKER_TMP_DOWNLOAD_PATH=/home/"$USER"/tmp

sudo mkdir $DOCKER_TMP_DOWNLOAD_PATH
cd $DOCKER_TMP_DOWNLOAD_PATH
curl "$DOCKER_DOWNLOAD_URLS"/containerd.io_1.7.25-1_amd64.deb -o containerd.io_1.7.25-1_amd64.deb
curl "$DOCKER_DOWNLOAD_URLS"/docker-buildx-plugin_0.21.1-1~ubuntu.24.04~noble_amd64.deb -o docker-buildx-plugin_0.21.1-1~ubuntu.24.04~noble_amd64.deb
curl "$DOCKER_DOWNLOAD_URLS"/docker-ce-cli_28.0.1-1~ubuntu.24.04~noble_amd64.deb -o docker-ce-cli_28.0.1-1~ubuntu.24.04~noble_amd64.deb   
curl "$DOCKER_DOWNLOAD_URLS"/docker-ce-rootless-extras_28.0.1-1~ubuntu.24.04~noble_amd64.deb -o docker-ce-rootless-extras_28.0.1-1~ubuntu.24.04~noble_amd64.deb
curl "$DOCKER_DOWNLOAD_URLS"/docker-ce_28.0.1-1~ubuntu.24.04~noble_amd64.deb  -o docker-ce_28.0.1-1~ubuntu.24.04~noble_amd64.deb
curl "$DOCKER_DOWNLOAD_URLS"/docker-compose-plugin_2.33.1-1~ubuntu.24.04~noble_amd64.deb  -o docker-compose-plugin_2.33.1-1~ubuntu.24.04~noble_amd64.deb

sudo dpkg -i containerd.io_1.7.25-1_amd64.deb \
             docker-buildx-plugin_0.21.1-1~ubuntu.24.04~noble_amd64.deb \
             docker-ce-cli_28.0.1-1~ubuntu.24.04~noble_amd64.deb \
             docker-ce-rootless-extras_28.0.1-1~ubuntu.24.04~noble_amd64.deb \
             docker-ce_28.0.1-1~ubuntu.24.04~noble_amd64.deb \
             docker-compose-plugin_2.33.1-1~ubuntu.24.04~noble_amd64.deb

cd /home/"$USER"
rm -rf $DOCKER_TMP_DOWNLOAD_PATH

#--------------------------------------------------------------------------------------------------------------------------------#
## 2. Post-installation
#--------------------------------------------------------------------------------------------------------------------------------#
# post-installation
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo usermod -aG docker $USER
sudo mkdir /home/"$USER"/.docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

# start on boot with systemd
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
# disable boot with systemd
# sudo systemctl disable docker.service
# sudo systemctl disable containerd.service



# offline install using deb
# curl https://github.com/NVIDIA/libnvidia-container/blob/gh-pages/stable/deb/amd64/nvidia-container-toolkit_1.17.4-1_amd64.deb
# deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/amd64 /
# #deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/experimental/ubuntu18.04/amd64 /
# sudo apt-get update
# sudo apt-get install -y nvidia-container-toolkit
# sudo nvidia-ctk runtime configure --runtime=docker
# sudo systemctl restart docker

# https://raw.githubusercontent.com/NVIDIA/libnvidia-container/gh-pages/stable/deb/amd64/nvidia-container-toolkit_1.17.0-1_amd64.deb
# https://raw.githubusercontent.com/NVIDIA/libnvidia-container/gh-pages/stable/deb/amd64/nvidia-container-toolkit-base_1.17.0-1_amd64.deb
# https://raw.githubusercontent.com/NVIDIA/libnvidia-container/gh-pages/stable/deb/amd64/libnvidia-container-tools_1.17.0-1_amd64.deb
# https://raw.githubusercontent.com/NVIDIA/libnvidia-container/gh-pages/stable/deb/amd64/libnvidia-container1-dbg_1.17.0-1_amd64.deb
# https://raw.githubusercontent.com/NVIDIA/libnvidia-container/gh-pages/stable/deb/amd64/libnvidia-container1_1.17.0-1_amd64.deb
#------------------------------------------------------------------------------------
#
# install docker-compose
#
#------------------------------------------------------------------------------------
# DOCKER_COMPOSE_VERSION='v2.33.1'
# sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
#           -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose

# for the issue of 7EA0A9C3F273FCD8
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8