# Install Node.js

This script installs a specific version of Node.js (v22.20.0) manually to `/opt/node` and configures the npm mirror.

## Overview of Changes
The script performs the following actions:
1.  **Downloads Node.js**: Fetches the specified Node.js binary archive.
2.  **Installs Node.js**: Extracts the archive to `/opt/node/v22.20.0`.
3.  **Configures Environment**: Adds the Node.js bin directory to the system `PATH` via `/etc/profile.d/node-v22.20.0.sh`.
4.  **Configures Mirror**: Sets the global npm registry to `https://registry.npmmirror.com/`.

## Prerequisites
- **Root Access**: You must run the script as root (using `sudo`) for installation.
- **Network Connection**: Required to download the archive.

## Usage

The script supports two modes: `download` and `install`.

### 1. Make the Script Executable
```bash
chmod +x step02_install_node.sh
```

### 2. Download Node.js
First, download the archive to a temporary location:
```bash
./step02_install_node.sh download
```

### 3. Install Node.js
Then, install the downloaded archive:
```bash
sudo ./step02_install_node.sh install
```

### 4. Verify
After installation, you may need to log out and log back in or source the profile to see the changes.
```bash
source /etc/profile.d/node-v22.20.0.sh
node --version
npm config get registry
```
