#------------------------------------------------------------------------------------
#
# install nvidia-docker
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
#
#------------------------------------------------------------------------------------

# setup GPG package respository key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# install nvidia-docker
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# configure nvidia-docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# In case of Error with ln
# sudo rm /usr/lib/wsl/lib/libcuda.so.1
# sudo ln -s /usr/lib/wsl/lib/libcuda.so.1.1 /usr/lib/wsl/lib/libcuda.so.1
# sudo ldconfig