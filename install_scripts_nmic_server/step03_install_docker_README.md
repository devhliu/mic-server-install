# Install Docker

This script installs Docker Engine, Docker CLI, containerd, and Docker Compose plugin, and configures Docker Hub mirrors for faster image pulls in China.

## Overview of Changes
The script performs the following actions:
1.  **Installs Dependencies**: Installs `ca-certificates` and `curl`.
2.  **Adds Docker GPG Key**: Downloads the official Docker GPG key from Aliyun mirror.
3.  **Adds Docker Repository**: Configures the APT source list to use Aliyun's Docker mirror.
4.  **Installs Docker Packages**: Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, etc.
5.  **Configures Daemon**: Creates `/etc/docker/daemon.json` with a list of registry mirrors.
6.  **Configures User Group**: Adds the current user to the `docker` group to run docker commands without `sudo`.
7.  **Cleans Up**: Offers to remove dangling docker images.

## Prerequisites
- **Root Access**: You must run the script as root (using `sudo`).
- **Network Connection**: Required to download packages and images.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step03_install_docker.sh
```

### 2. Run the Script
```bash
sudo ./step03_install_docker.sh
```

### 3. Verify
After installation, verify Docker is running and mirrors are configured:
```bash
docker info
```
Check the "Registry Mirrors" section in the output.
You should also be able to run docker commands without sudo (after logging out and back in or using `newgrp docker` as prompted).
