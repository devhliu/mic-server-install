#!/bin/bash

sudo groupadd docker
sudo usermod -aG docker $USER
mkdir /home/$USER/.docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo groupadd microk8s
sudo usermod -aG microk8s $USER
sudo chown -f -R $USER ~/.mic