# Install Ubuntu Base Configuration

This script configures the Ubuntu system with Chinese mirrors (PKU) for faster package downloads and updates the system packages.

## Overview of Changes
The script performs the following actions:
1.  **Detects Ubuntu Version**: Identifies the current Ubuntu codename (e.g., noble for 24.04).
2.  **Configures APT Mirrors**: Replaces the default Ubuntu repositories with Peking University (PKU) mirrors.
3.  **Removes Conflicting Sources**: Ensures `ubuntu.sources` (used in newer Ubuntu versions) is removed to prioritize `sources.list`.
4.  **Updates System**: Runs `apt-get update`, `upgrade`, and `autoremove` to ensure the system is up-to-date.

## Prerequisites
- **Root Access**: You must run the script as root (using `sudo`).
- **Network Connection**: Required to access the mirror and download updates.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step00_install_ubuntu.sh
```

### 2. Run the Script
```bash
sudo ./step00_install_ubuntu.sh
```

### 3. Verify
Check if the `sources.list` file has been updated:
```bash
cat /etc/apt/sources.list
```
You should see URLs pointing to `mirrors.pku.edu.cn`.
