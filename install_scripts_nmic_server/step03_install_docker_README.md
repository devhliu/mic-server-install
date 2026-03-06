# Install Docker

This script installs Docker Engine, Docker CLI, containerd, and Docker Compose plugin, and configures Docker Hub mirrors for faster image pulls in China.

## Overview of Changes
The script performs the following actions:
1.  **Installs Dependencies**: Installs `ca-certificates` and `curl`.
2.  **Adds Docker GPG Key**: Downloads the official Docker GPG key (with China mirror fallbacks).
3.  **Adds Docker Repository**: Configures the APT source list (auto-selects a reachable mirror).
4.  **Installs Docker Packages**: Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, etc.
5.  **Configures Daemon**: Creates `/etc/docker/daemon.json` with registry mirrors.
6.  **Enables Services**: Enables and starts `docker` and `containerd` so they run on boot.
7.  **Configures Permissions**: Adds the current user to the `docker` group for rootless usage.
8.  **Cleans Up**: Offers to remove dangling docker images.

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

### 3. Apply Group Changes
To use Docker without `sudo`, start a new shell session so group membership takes effect:
```bash
newgrp docker
```
Alternatively, log out and back in.

### 4. Verify
Verify Docker is running and mirrors are configured:
```bash
docker info
```
Check the "Registry Mirrors" section in the output.
If you haven’t refreshed your session yet, use `sudo docker …` temporarily.
