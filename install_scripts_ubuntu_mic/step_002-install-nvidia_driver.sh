#!/bin/bash

# download and install driver
# NVIDIA_PYTORCH_VERSION=22.08
# CUDA_VERSION=11.7.1.017 CUDA_DRIVER_VERSION=515.65.01
# wget https://us.download.nvidia.cn/tesla/515.65.01/nvidia-driver-local-repo-ubuntu2004-515.65.01_1.0-1_amd64.deb
# CUDA_VERSION=12.2
# wget https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run
# install using bed for ununtu 20.04
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda-repo-ubuntu2004-12-2-local_12.2.2-535.104.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-12-2-local_12.2.2-535.104.05-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2004-12-2-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda

# install nvidia-smi
# apt-get install nvidia-utils-515