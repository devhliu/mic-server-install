# NMIC Server Installation

## Overview

This project provides a comprehensive set of scripts to set up a robust Vibe Coding development environment on Ubuntu 24.04. The installation is optimized for performance and reliability, featuring pre-configured mirrors for the China region to ensure fast package downloads.

## Prerequisites

- **Operating System**: Ubuntu 24.04 (Noble Numbat) or later.
- **Privileges**: Sudo access is required for most installation steps.
- **Internet Connection**: Required for downloading packages and tools.

## Installation Steps

### [step00_install_ubuntu.sh](file:///home/ngi/devhliu/nmic-server-install/step00_install_ubuntu.sh) - System Optimization
Configures the Ubuntu system with high-speed mirrors and updates all packages.
- **Mirror**: Peking University (PKU) mirror (`https://mirrors.pku.edu.cn/ubuntu/`).
- **Actions**: Updates `/etc/apt/sources.list`, removes conflicting source files (for Ubuntu 24.04+), and performs a full system upgrade (`apt-get upgrade`).

### [step01_install_python.sh](file:///home/ngi/devhliu/nmic-server-install/step01_install_python.sh) - Python & Conda
Installs a managed Python environment using Miniconda3.
- **Version**: Miniconda3-py312_25.9.1-3 (Python 3.12).
- **Location**: Installed to `/opt/miniconda3`.
- **System Integration**: Configures `/etc/profile.d/miniconda.sh` for system-wide `PATH` access.
- **Mirrors**: 
  - **Pip**: PKU Mirror (`https://pypi.mirrors.pku.edu.cn/simple`).
  - **Conda**: PKU Mirror channels (`free`, `main`).

### [step02_install_node.sh](file:///home/ngi/devhliu/nmic-server-install/step02_install_node.sh) - Node.js Environment
Sets up a specific Node.js version for development.
- **Version**: Node.js v22.20.0.
- **Location**: Installed to `/opt/node/v22.20.0`.
- **System Integration**: Configures `/etc/profile.d/node-v22.20.0.sh` for system-wide `PATH` access.
- **Mirror**: NpmMirror (`https://registry.npmmirror.com/`).
- **Usage**: Supports `download` and `install` commands separately.

### [step03_install_docker.sh](file:///home/ngi/devhliu/nmic-server-install/step03_install_docker.sh) - Docker & Docker Compose
Installs the latest Docker Engine and Docker Compose plugin.
- **Repo Mirror**: Aliyun (`https://mirrors.aliyun.com/docker-ce/linux/ubuntu`).
- **Registry Mirrors**: Configures multiple mirrors in `/etc/docker/daemon.json` (including 1ms.run, Aliyun, Baidu, Tencent, SJTU, etc.) to ensure reliable image pulling.
- **Post-Install**: Automatically adds the current user to the `docker` group.

### [step04_install_vibecoding_cli.sh](file:///home/ngi/devhliu/nmic-server-install/step04_install_vibecoding_cli.sh) - AI Coding Tools
Installs essential CLI tools for modern AI-assisted development (Vibe Coding).
- **Tools**:
  - `claude-code`: Anthropic's Claude Code CLI.
  - `opencode-ai`: OpenCode AI assistant.
  - `codebuddy-code`: Tencent's CodeBuddy CLI.
  - `copilot`: GitHub Copilot CLI.

## Usage

To set up your server, run the scripts in order:

```bash
# Make all scripts executable
chmod +x step*.sh

# Step 0: Optimize Ubuntu mirrors and update system
./step00_install_ubuntu.sh

# Step 1: Install Python/Conda and configure mirrors
./step01_install_python.sh

# Step 2: Download and install Node.js
./step02_install_node.sh download
./step02_install_node.sh install

# Step 3: Install Docker and Docker Compose
./step03_install_docker.sh

# Step 4: Install AI coding CLI tools
./step04_install_vibecoding_cli.sh
```

## Installed Components

- **Python**: Miniconda3-py312 (Python 3.12)
- **Node.js**: v22.20.0
- **Docker**: Latest from Docker CE
- **CLI Tools**: Claude Code, Opencode, Codebuddy, GitHub Copilot

## Post-Installation

After running **Step 3**, you need to refresh your group membership to use Docker without `sudo`:

```bash
newgrp docker
```

Alternatively, log out and log back in.

## Configuration Details

For a full list of configured mirrors and registry settings, refer to [mirrors.yaml](file:///home/ngi/devhliu/nmic-server-install/mirrors.yaml).
