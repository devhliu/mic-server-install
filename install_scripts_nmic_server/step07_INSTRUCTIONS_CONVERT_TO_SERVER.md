# Convert Ubuntu Desktop to Server (Remove GNOME & Snapd)

This guide provides instructions and a bash script to convert a standard Ubuntu 24.04 Desktop installation into a lightweight, server-oriented system by removing the GNOME desktop environment and the Snapd package manager.

## Overview of Changes
The script performs the following actions:
1.  **Removes Snapd**: Uninstalls all Snap packages and the Snapd daemon to free up resources and prevent background updates.
2.  **Removes GNOME Desktop**: Uninstalls the graphical user interface (GUI), including `ubuntu-desktop`, `gnome-shell`, `gdm3`, and Xorg.
3.  **Installs Server Utilities**: Ensures essential server packages (`ubuntu-server`) are installed.
4.  **Configures Boot Target**: Sets the system to boot directly into the command-line interface (`multi-user.target`) instead of trying to load a GUI.
5.  **Cleans Up**: Removes unused dependencies and configuration files.

## Prerequisites
- **Root Access**: You must run the script as root (using `sudo`).
- **Network Connection**: Required to download server packages.
- **Backup**: This process is destructive to the GUI. Ensure you have backed up important data.
- **SSH Access**: Ideally, ensure you can SSH into the machine before running this, as you will lose the local graphical console.

## Step-by-Step Instructions

### 1. Download/Create the Script
Save the provided bash script as `convert_to_server.sh` on the target machine.

### 2. Make the Script Executable
Run the following command to give execution permissions:
```bash
chmod +x convert_to_server.sh
```

### 3. Run the Script
Execute the script with root privileges:
```bash
sudo ./convert_to_server.sh
```

### 4. Confirm Execution
The script will display a warning and ask for confirmation. Type `YES` to proceed.

### 5. Post-Installation Steps
After the script completes:
1.  **Check Network Configuration**: Verify your network settings are still valid using `ip a`.
2.  **Reboot**: Restart the system to apply all changes.
    ```bash
    sudo reboot
    ```
3.  **Verify**: Upon reboot, the system should present a text-based login prompt instead of a graphical login screen.

## Troubleshooting
- **Network Issues**: If network connectivity is lost after reboot, check `/etc/netplan/` configuration files. Desktop installs often use NetworkManager renderer, while Server installs use networkd. You might need to edit the YAML file in `/etc/netplan/` to use `renderer: networkd` if NetworkManager was removed.
- **Restoring GUI**: If you need the GUI back, you can reinstall it:
    ```bash
    sudo apt update
    sudo apt install ubuntu-desktop
    sudo systemctl set-default graphical.target
    ```
