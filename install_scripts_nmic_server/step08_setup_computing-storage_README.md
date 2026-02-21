# Server Storage Setup Instructions

This document provides instructions for setting up the storage configuration for the Computing Server and Data Server using the provided `setup_storage.sh` script.

## System Requirements
- **OS**: Ubuntu 24.04 (as specified)
- **Computing Server IP**: `<COMPUTING_SERVER_IP>` (or pre-defined)
- **Data Server IP**: `<DATA_SERVER_IP>` (or pre-defined)
- **Root Privileges**: The script must be run as root (using `sudo`).

## Overview
The setup involves two main parts:
1.  **Data Server**: Creates `/data` and exports it via NFS.
2.  **Computing Server**: Creates `/data01`, `/data02` and mounts the remote `/data` to `/data02`.

## Step-by-Step Guide

### Step 1: Configure the Data Server
Run the script on the machine with IP `<DATA_SERVER_IP>`.

1.  Transfer the `setup_storage.sh` script to the server.
2.  Make the script executable:
    ```bash
    chmod +x setup_storage.sh
    ```
3.  Run the script with root privileges:
    ```bash
    sudo ./setup_storage.sh
    ```
4.  Select **Option 2** (Data Server) when prompted.
5.  The script will:
    - Install `nfs-kernel-server`.
    - Create the `/data` directory.
    - Configure `/etc/exports` to allow access from the Computing Server.
    - Restart the NFS service.

### Step 2: Configure the Computing Server
Run the script on the machine with IP `<COMPUTING_SERVER_IP>`.

1.  Transfer the `setup_storage.sh` script to the server.
2.  Make the script executable:
    ```bash
    chmod +x setup_storage.sh
    ```
3.  Run the script with root privileges:
    ```bash
    sudo ./setup_storage.sh
    ```
4.  Select **Option 1** (Computing Server) when prompted.
5.  The script will:
    - Install `nfs-common`.
    - Create `/data01` and `/data02`.
    - Configure `/etc/fstab` to mount the remote `/data` volume to `/data02`.
    - Reload systemd and attempt to mount.

## Automatic Mounting Features
The Computing Server is configured with robust mount options in `/etc/fstab`:

- `defaults`: Standard mount options.
- `nofail`: Ensures the server boots successfully even if the Data Server is offline.
- `x-systemd.automount`: **Key Feature**. The filesystem is mounted automatically upon access (e.g., when you `cd /data02` or list files). This handles the requirement to "automatically mount it when the IP-dataserver is connected".
- `_netdev`: Ensures the system waits for the network to be online before attempting to mount.

## Verification

### On Computing Server
To check if the mount is active:
```bash
mount | grep /data02
```
If you see an entry, it is mounted.

If it is not mounted, you can trigger the automount by accessing the directory:
```bash
ls /data02
```
If the Data Server is reachable, this command should succeed and mount the directory.

### Troubleshooting
- **Warning: /data02 is NOT mounted yet**: This is normal if the Data Server is not reachable yet. The `x-systemd.automount` feature will retry when you access the directory.
- **Permission Denied**: Check firewall rules (UFW) on the Data Server to ensure port 2049 (NFS) is open to the Computing Server IP.
  ```bash
  sudo ufw allow from <COMPUTING_SERVER_IP> to any port nfs
  ```
