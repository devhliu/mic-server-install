# Install Python (Miniconda)

This script installs Miniconda (Python 3.12) and configures PyPI and Conda mirrors for faster access in China.

## Overview of Changes
The script performs the following actions:
1.  **Downloads Miniconda**: Fetches the Miniconda installer from the PKU mirror.
2.  **Installs Miniconda**: Installs Miniconda to `/opt/miniconda3`.
3.  **Configures Environment**: Adds Miniconda bin directory to the system `PATH` via `/etc/profile.d/miniconda.sh`.
4.  **Configures Mirrors**:
    - Sets `pip` index URL to PKU mirror globally in `/etc/pip.conf`.
    - Adds PKU Conda channels to the system-wide Conda configuration.

## Prerequisites
- **Root Access**: You must run the script as root (using `sudo`).
- **Network Connection**: Required to download the installer.
- **Tools**: Requires `curl` or `wget`.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step01_install_python.sh
```

### 2. Run the Script
```bash
sudo ./step01_install_python.sh
```

### 3. Verify
After installation, you may need to log out and log back in or source the profile to see the changes.
```bash
source /etc/profile.d/miniconda.sh
conda --version
pip config list
```
