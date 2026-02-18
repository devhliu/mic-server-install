#!/bin/bash

# update the ubuntu system

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt update -y 
sudo apt upgrade -y

sudo apt autoremove -y 

conda update --all -y
conda clean --all -y
conda clean -f -y

clear