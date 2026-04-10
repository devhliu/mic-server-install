# MIC Server Install

**Version: 0.1.0**

A comprehensive collection of installation scripts and utilities for setting up development environments on Ubuntu systems, with optimized configurations for users in China.

## Quick Start

Choose your installation profile:

### 🚀 Development Server (Recommended)
```bash
cd install_scripts_dev-mic_server
./step00_install_ubuntu.sh
./step01_install_python.sh
./step02_install_node.sh download && ./step02_install_node.sh install
./step03_install_docker.sh
./step04_install_vibecoding_cli.sh
./step05_install_vibecoding_skills.sh
```

### 🏭 Production Server
```bash
cd install_scripts_nmic_server
./step00_install_ubuntu.sh
./step01_install_python.sh
./step02_install_node.sh download && ./step02_install_node.sh install
./step03_install_docker.sh
./step04_install_vibecoding_cli.sh
```

### ☸️ Kubernetes (MicroK8s)
```bash
cd install_scripts_k8s
./install.sh
```

## Project Structure

```
mic-server-install/
├── common/                        # Shared utilities and configurations
│   ├── install_utils.sh          # Common bash functions
│   ├── mirrors.yaml              # Mirror configurations for China
│   └── README.md                 # Utilities documentation
│
├── install_scripts_dev-mic_server/  # Development environment
│   ├── README.MD                 # Detailed installation guide
│   ├── install_utils.sh          # Sources from common/
│   └── step*.sh                  # Installation scripts
│
├── install_scripts_nmic_server/  # Production environment
│   ├── README.MD                 # Detailed installation guide
│   ├── install_utils.sh          # Sources from common/
│   └── step*.sh                  # Installation scripts
│
├── install_scripts_k8s/          # Kubernetes (MicroK8s)
│   ├── README.md                 # Kubernetes setup guide
│   ├── install.sh                # Main installation script
│   ├── install_utils.sh          # Kubernetes-specific utilities
│   ├── steps/                    # Step-by-step installation
│   ├── docker/                   # Docker utilities
│   ├── gpu/                      # GPU support
│   ├── local-harbor/             # Harbor registry
│   └── storage-*/                # Storage configurations
│
└── docs/                         # Additional documentation
    ├── ubuntu_wsl/               # WSL-specific guides
    └── *.md                      # Various configuration guides
```

## Installation Profiles

### 1. Development Server (Dev MIC)

**Purpose**: Vibe Coding development environment with AI tools

**Key Features**:
- Python 3.12 (Miniconda3)
- Node.js v22.20.0
- Docker with multiple registry mirrors
- AI Coding Tools: Claude Code, Opencode, CodeBuddy, GitHub Copilot
- Hugging Face model downloader

**Detailed Guide**: [install_scripts_dev-mic_server/README.MD](install_scripts_dev-mic_server/README.MD)

### 2. Production Server (NMIC)

**Purpose**: Production-ready server configuration

**Key Features**:
- Same as Dev MIC plus:
- System optimization and cleanup scripts
- Storage management utilities
- Model downloaders (HuggingFace, ModelScope)

**Detailed Guide**: [install_scripts_nmic_server/README.MD](install_scripts_nmic_server/README.MD)

### 3. Kubernetes (MicroK8s)

**Purpose**: Local Kubernetes development cluster

**Key Features**:
- MicroK8s with GPU support
- Docker with NVIDIA runtime
- Helm 3 package manager
- OpenEBS storage
- Harbor container registry
- MetalLB load balancer

**Detailed Guide**: [install_scripts_k8s/README.md](install_scripts_k8s/README.md)

## Key Features

### 🌏 China Mirror Support

All installation scripts are pre-configured with China mirrors for faster downloads:

| Package Manager | Mirror |
|-----------------|--------|
| Ubuntu APT | PKU Mirror (`mirrors.pku.edu.cn`) |
| Python (Pip) | Tsinghua Mirror (`pypi.tuna.tsinghua.edu.cn`) |
| Python (Conda) | PKU Mirror (`mirrors.pku.edu.cn`) |
| NPM | NpmMirror (`registry.npmmirror.com`) |
| Docker | Multiple mirrors (Aliyun, Baidu, Tencent, SJTU) |
| HuggingFace | hf-mirror.com |

### 🔐 Intelligent Sudo Usage

Scripts automatically detect when sudo is needed:
- **System paths** (`/opt`, `/usr`, `/etc`): Automatically use sudo
- **User paths** (`$HOME`, `~`): Run without sudo

### 📦 Modular Design

- Each installation profile is self-contained
- Individual steps can be run independently
- Shared utilities reduce code duplication

## Common Operations

### Post-Installation

After installing Docker, refresh your group membership:

```bash
newgrp docker
# Or log out and log back in
```

### Verify Installation

```bash
# Python
python --version
conda --version

# Node.js
node --version
npm --version

# Docker
docker --version
docker run hello-world

# Kubernetes (if installed)
microk8s status
kubectl get nodes
```

### GPU Support

For NVIDIA GPU support:

```bash
cd install_scripts_k8s/gpu
./install.sh

# Verify
python torch_available.py
```

## Utilities

### Docker Utilities (`install_scripts_k8s/docker/`)

- `batch_save_docker_images.py` - Batch save Docker images to tar files
- `batch_retag_docker_images.py` - Batch retag and manage Docker images
- `utils.md` - Docker save/load commands
- `mirror.md` - Mirror configurations
- `clearn.md` - Docker cleanup commands

### Storage Configuration

- **OpenEBS**: `install_scripts_k8s/storage-openebs/` - Local storage
- **NFS**: `install_scripts_k8s/storage-nfs-harbor/` - NFS for Harbor

### Harbor Registry

Deploy a local Harbor container registry:

```bash
cd install_scripts_k8s/local-harbor
./install.sh
```

## Documentation

Additional documentation available in `docs/`:

- `harbor.md` - Harbor registry setup
- `microk8s_image_registy.md` - MicroK8s image registry configuration
- `microk8s_pvc.md` - Persistent volume claims
- `kubeapps.md` - Kubeapps installation
- `cn_mirror.md` - China mirror configurations
- `ubuntu_wsl/` - WSL-specific configurations

## Requirements

- **Operating System**: Ubuntu 20.04/24.04 LTS
- **Privileges**: Sudo access required for most installations
- **Network**: Internet connection for package downloads

## Contributing

When contributing:

1. Use shared utilities from `common/` directory
2. Follow the existing code structure
3. Test across all installation profiles
4. Update documentation as needed

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Author

devhliu@image.local.com
