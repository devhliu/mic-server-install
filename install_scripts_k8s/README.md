# MicroK8s Installation Scripts

This directory contains automated installation scripts for setting up a MicroK8s Kubernetes cluster with Docker and optional GPU support on Ubuntu 24.04 LTS.

## Features

- **Automated Installation**: Complete setup of MicroK8s, Docker, and dependencies
- **GPU Support**: Optional NVIDIA GPU support for machine learning workloads
- **China Mirror Support**: Built-in support for China mirrors (Tsinghua, pullk8s)
- **Offline Installation**: Support for offline installation mode
- **Conditional Sudo**: Intelligent sudo usage based on installation paths
- **Modular Design**: Step-by-step installation with individual scripts

## Quick Start

### Basic Installation

```bash
# Clone or navigate to the installation directory
cd /path/to/install_scripts_k8s

# Run the main installation script
./install.sh
```

### Custom Installation

```bash
# Install specific MicroK8s version
./install.sh --microk8s-version 1.24/stable

# Install with custom DNS server
./install.sh --dns-server 10.6.2.6

# Install without GPU support
./install.sh --no-gpu

# Install in offline mode
OFFLINE_MODE=true ./install.sh
```

## Installation Steps

The installation is divided into the following steps:

1. **Step 001**: Configure Ubuntu (APT mirrors, basic packages, kernel parameters)
2. **Step 002**: Install Docker (with optional offline mode)
3. **Step 003**: Install NVIDIA Docker (optional, GPU support)
4. **Step 004**: Install MicroK8s (Kubernetes cluster)
5. **Step 005**: Configure MicroK8s (API server, controller manager, kubelet)
6. **Step 006**: Install Helm (Kubernetes package manager)

Each step can be run individually:

```bash
# Run individual steps
./steps/step_001_config_ubuntu.sh
./steps/step_002_install_docker.sh
./steps/step_003_install_nvidia_docker.sh
./steps/step_004_install_microk8s.sh
./steps/step_005_configure_microk8s.sh
./steps/step_006_install_helm.sh
```

## Configuration Options

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MICROK8S_VERSION` | `1.28/stable` | MicroK8s version/channel |
| `DNS_SERVER` | Auto-detect | DNS server IP address |
| `GPU_ENABLED` | `true` | Enable GPU support |
| `OFFLINE_MODE` | `false` | Install in offline mode |
| `USE_CHINA_MIRROR` | `true` | Use China mirrors |
| `HELM_VERSION` | `3.13.0` | Helm version to install |
| `DOCKER_VERSION` | Latest | Docker version (empty for latest) |

### Command Line Options

```bash
./install.sh [OPTIONS]

Options:
    --microk8s-version VERSION    MicroK8s version/channel (default: 1.28/stable)
    --dns-server IP              DNS server IP (default: auto-detect)
    --no-gpu                     Disable GPU support
    --offline                    Install in offline mode
    -h, --help                   Show help message
```

## Directory Structure

```
install_scripts_k8s/
├── README.md                          # This file
├── install_utils.sh                   # Shared utility functions
├── install.sh                         # Main installation script
├── steps/                             # Step-by-step installation scripts
│   ├── step_001_config_ubuntu.sh     # Configure Ubuntu
│   ├── step_002_install_docker.sh    # Install Docker
│   ├── step_003_install_nvidia_docker.sh  # Install NVIDIA Docker
│   ├── step_004_install_microk8s.sh  # Install MicroK8s
│   ├── step_005_configure_microk8s.sh # Configure MicroK8s
│   └── step_006_install_helm.sh      # Install Helm
├── docker/                            # Docker utilities
│   ├── batch_retag_docker_images.py   # Batch retag Docker images
│   ├── batch_save_docker_images.py    # Batch save Docker images
│   ├── clearn.md                      # Docker cleanup guide
│   ├── mirror.md                      # Docker mirror configuration
│   └── utils.md                       # Docker utilities documentation
├── python/                            # Python utilities
│   ├── clean_pycache.py               # Clean Python cache
│   └── package_info.py                # Package information
├── nodejs/                            # Node.js utilities
│   └── install.sh                     # Node.js installation
├── gpu/                               # GPU utilities
│   ├── install.sh                     # GPU driver installation
│   └── torch_available.py             # Check PyTorch GPU availability
├── local-harbor/                      # Harbor registry deployment
│   ├── install.sh                     # Harbor installation script
│   ├── uih-harbor-values.yaml         # Harbor values configuration
│   ├── uih-harbor-datastorage-pv.yaml # Harbor persistent volume
│   └── bitnami-harbor/                # Bitnami Harbor Helm chart
├── storage-openebs/                   # OpenEBS storage
│   ├── readme.md                      # OpenEBS documentation
│   ├── local-hostpath-pvc.yaml        # Hostpath PVC example
│   ├── local-hostpath-pod.yaml        # Hostpath pod example
│   └── local-openebs-sc.yaml          # OpenEBS storage class
├── storage-nfs-harbor/                # NFS storage for Harbor
│   ├── ubuntu_microk8s_storage.sh     # NFS storage setup
│   ├── nfs-sc.yaml                    # NFS storage class
│   ├── nfs-pv.yaml                    # NFS persistent volume
│   ├── nfs-pvc.yaml                   # NFS persistent volume claim
│   └── pvc-nfs-harbor.yaml            # Harbor NFS PVC
├── helm/                              # Helm installation
│   └── get_helm.sh                    # Helm installation script
├── hosts/                             # Hosts configuration
│   └── hosts.md                       # Hosts file documentation
├── microk8s-system-dockers.config     # MicroK8s Docker configuration
├── ingress-service.yaml               # Ingress service example
└── compress_wsl_vdisk.md              # WSL disk compression guide
```

## Post-Installation

After installation completes:

1. **Log out and log back in** for group changes to take effect
2. **Verify the installation**:

```bash
# Check MicroK8s status
microk8s status

# Check nodes
kubectl get nodes

# Check pods
kubectl get pods --all-namespaces

# Check Docker
docker version

# Check Helm
helm version
```

## Common Operations

### Access MicroK8s Dashboard

```bash
# Enable dashboard
microk8s enable dashboard

# Access dashboard
microk8s dashboard-proxy
```

### Deploy an Application

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx

# Expose the deployment
kubectl expose deployment nginx --port=80 --target-port=80 --name=nginx-service

# Access the service
kubectl get svc
```

### Use Helm

```bash
# Add a Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Search for charts
helm search repo bitnami

# Install a chart
helm install my-nginx bitnami/nginx
```

## Troubleshooting

### MicroK8s Not Starting

```bash
# Check MicroK8s status
microk8s status

# Check logs
microk8s inspect

# Restart MicroK8s
microk8s stop
microk8s start
```

### Docker Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in
```

### GPU Not Detected

```bash
# Check NVIDIA GPU
lspci | grep -i nvidia

# Check NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
```

## Utilities

### Docker Utilities

- **batch_retag_docker_images.py**: Batch retag Docker images for mirror migration
- **batch_save_docker_images.py**: Batch save Docker images to tar files
- **clearn.md**: Docker cleanup commands and best practices
- **mirror.md**: Docker mirror configuration guide
- **utils.md**: Docker utilities documentation

### Python Utilities

- **clean_pycache.py**: Clean Python cache files recursively
- **package_info.py**: Display Python package information

### GPU Utilities

- **install.sh**: GPU driver installation script
- **torch_available.py**: Check PyTorch GPU availability

## Additional Resources

- [MicroK8s Documentation](https://microk8s.io/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Helm Documentation](https://helm.sh/docs/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html)

## Contributing

When contributing to this repository, please:

1. Follow the existing code structure
2. Use the shared utility functions from `install_utils.sh`
3. Test your changes thoroughly
4. Update documentation as needed

## License

This project is provided as-is for internal use. Please refer to individual component licenses for third-party software.
