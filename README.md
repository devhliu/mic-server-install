# MIC Server Install

A comprehensive collection of installation scripts and utilities for setting up Kubernetes (MicroK8s) development environments on Ubuntu systems, with optimized configurations for users in China.

## Project Structure

```
kubemic-install/
├── install_scripts_ubuntu_mic/    # MicroK8s installation for Ubuntu WSL/Desktop
│   ├── steps/                     # Step-by-step installation scripts
│   ├── docker/                    # Docker utilities and scripts
│   ├── gpu/                       # GPU/NVIDIA driver setup
│   ├── python/                    # Python utilities
│   ├── nodejs/                    # Node.js installation
│   ├── helm/                      # Helm installation
│   ├── storage-openebs/           # OpenEBS storage configuration
│   ├── storage-nfs-harbor/        # NFS storage for Harbor
│   ├── local-harbor/              # Harbor registry deployment
│   └── hosts/                     # Hosts configuration
│
├── install_scripts_dev-mic_server/ # Development server setup (Ubuntu 24.04)
│   └── Vibe Coding environment with AI tools
│
├── install_scripts_nmic_server/   # NMIC server setup (Ubuntu 24.04)
│   └── Production server configuration
│
└── docs/                          # Documentation and guides
    ├── ubuntu_wsl/                # WSL-specific configurations
    └── Various configuration guides
```

## Installation Profiles

### 1. Ubuntu MIC (MicroK8s on Ubuntu WSL/Desktop)

For setting up a local Kubernetes development environment with MicroK8s:

**Prerequisites**: Ubuntu 20.04/24.04 LTS

```bash
cd install_scripts_ubuntu_mic

# Full installation
./install-ubuntu_20.04-microk8s.sh

# Or step-by-step:
./steps/step_001_config_ubuntu.sh
./steps/step_002_install_minianaconda3.sh
./steps/step_003_install_docker.sh
./steps/step_004_install_nvidia_docker.sh  # If GPU available
```

**Features**:
- MicroK8s with GPU support
- Docker with NVIDIA runtime
- Helm 3 package manager
- OpenEBS storage
- Harbor container registry
- MetalLB load balancer

### 2. Dev MIC Server (Development Server)

For setting up a Vibe Coding development environment on Ubuntu 24.04:

```bash
cd install_scripts_dev-mic_server

chmod +x step*.sh

./step00_install_ubuntu.sh        # System optimization with PKU mirrors
./step01_install_python.sh        # Miniconda3 with Python 3.12
./step02_install_node.sh download # Download Node.js v22
./step02_install_node.sh install  # Install Node.js
./step03_install_docker.sh        # Docker + Docker Compose
./step04_install_vibecoding_cli.sh # AI coding tools
./step05_install_vibecoding_skills.sh # AI coding skills
./step06_install_huggingface-models.sh -m <model> # Download HF models
```

**Installed Components**:
- Python: Miniconda3-py312 (Python 3.12)
- Node.js: v22.20.0
- Docker: Latest CE with multiple registry mirrors
- AI Tools: Claude Code, Opencode, Codebuddy, GitHub Copilot

### 3. NMIC Server (Production Server)

Similar to Dev MIC Server but optimized for production:

```bash
cd install_scripts_nmic_server

chmod +x step*.sh

./step00_install_ubuntu.sh
./step01_install_python.sh
./step02_install_node.sh download
./step02_install_node.sh install
./step03_install_docker.sh
./step04_install_vibecoding_cli.sh
```

## Docker Utilities

Located in `install_scripts_ubuntu_mic/docker/`:

| File | Description |
|------|-------------|
| `utils.md` | Docker save/load commands |
| `mirror.md` | Mirror configurations for various package managers |
| `clearn.md` | Docker cleanup commands |
| `batch_save_docker_images.py` | Batch save Docker images to tar files |
| `batch_retag_docker_images.py` | Batch retag and manage Docker images |

## Storage Configuration

### OpenEBS (Local Storage)

```bash
cd install_scripts_ubuntu_mic/storage-openebs
kubectl apply -f local-openebs-sc.yaml
```

### NFS Storage (for Harbor)

```bash
cd install_scripts_ubuntu_mic/storage-nfs-harbor
./ubuntu_microk8s_storage.sh
```

## Harbor Registry

Deploy a local Harbor container registry:

```bash
cd install_scripts_ubuntu_mic/local-harbor
./install.sh
```

## GPU Support

For NVIDIA GPU support:

```bash
cd install_scripts_ubuntu_mic/gpu
./install.sh
```

Verify GPU availability:
```bash
python torch_available.py
```

## Mirror Configurations (China)

All installation scripts are pre-configured with China mirrors for faster downloads:

| Package Manager | Mirror |
|-----------------|--------|
| Ubuntu APT | PKU Mirror (`mirrors.pku.edu.cn`) |
| Pip | PKU Mirror (`pypi.mirrors.pku.edu.cn`) |
| Conda | PKU Mirror channels |
| NPM | NpmMirror (`registry.npmmirror.com`) |
| Docker | Multiple mirrors (Aliyun, Baidu, Tencent, SJTU) |
| HuggingFace | hf-mirror.com |

## WSL2 Specific

For WSL2-specific configurations:

```bash
cd docs/ubuntu_wsl
./snapd_wsl2.sh  # Enable snapd in WSL2
```

## Documentation

Additional documentation available in `docs/`:

- `harbor.md` - Harbor registry setup
- `microk8s_image_registy.md` - MicroK8s image registry configuration
- `microk8s_pvc.md` - Persistent volume claims
- `kubeapps.md` - Kubeapps installation
- `cn_mirror.md` - China mirror configurations
- `clean_microk8s_repos.md` - Cleanup MicroK8s repositories

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Author

devhliu@image.local.com
