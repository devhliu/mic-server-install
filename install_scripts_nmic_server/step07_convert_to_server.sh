#!/bin/bash

# ==============================================================================
# Script Name: convert_to_server.sh
# Description: Converts Ubuntu 24.04 Desktop to Server by removing GNOME & Snapd
#              and configuring for headless operation.
# WARNING: This script removes the graphical interface and all snap packages.
#          Ensure you have backups and SSH access before proceeding.
# ==============================================================================

# 1. Check for Root Privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "=============================================================================="
echo " WARNING: This script will perform the following destructive actions:"
echo " 1. Remove GNOME Desktop Environment (GUI)."
echo " 2. Remove all Snap packages and the Snapd daemon."
echo " 3. Install Ubuntu Server utilities."
echo " 4. Set the system to boot into command-line mode (multi-user.target)."
echo "=============================================================================="
read -p "Are you sure you want to proceed? (Type 'YES' to confirm): " confirm

if [ "$confirm" != "YES" ]; then
    echo "Operation cancelled."
    exit 0
fi

echo "[1/6] Removing all installed Snap packages..."
# Get list of installed snaps
snaps=$(snap list | awk 'NR>1 {print $1}')

# Loop through and remove each snap
# Note: Some snaps might depend on others, so we might need multiple passes or specific order.
# A simple loop usually works as snap tries to handle dependencies, but we'll be aggressive.
for snap in $snaps; do
    echo "Removing snap: $snap"
    snap remove --purge "$snap"
done

# Second pass to catch any remaining ones
snaps_remaining=$(snap list 2>/dev/null | awk 'NR>1 {print $1}')
if [ -n "$snaps_remaining" ]; then
    for snap in $snaps_remaining; do
        snap remove --purge "$snap"
    done
fi

echo "[2/6] Removing Snapd and preventing re-installation..."
systemctl stop snapd
systemctl disable snapd
apt-get purge -y snapd

# Prevent snapd from being installed again
cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# Clean up snap directories
rm -rf /root/snap /home/*/snap /var/cache/snapd /var/snap /var/lib/snapd

echo "[3/6] Removing GNOME Desktop and GUI packages..."
# Remove the main desktop metapackages
apt-get purge -y ubuntu-desktop ubuntu-desktop-minimal gnome-shell gdm3 xorg

# Remove other common GUI/desktop packages often found in standard install
apt-get purge -y \
    aisleriot brltty duplicity empathy empathy-common example-content \
    gnome-accessibility-themes gnome-contacts gnome-mahjongg gnome-mines \
    gnome-orca gnome-screensaver gnome-sudoku gnome-video-effects \
    landscape-common libsane libsane-common mcp-account-manager-uoa \
    python3-uno rhythmbox rhythmbox-plugins rhythmbox-plugin-zeitgeist \
    sane-utils shotwell shotwell-common telepathy-gabble telepathy-haze \
    telepathy-idle telepathy-indicator telepathy-logger telepathy-mission-control-5 \
    telepathy-salut totem totem-common totem-plugins printer-driver-splix \
    unity-greeter unity-lens-music unity-lens-photos unity-lens-video \
    unity-music-lens unity-scope-video-remote vnc4server zeitgeist \
    zeitgeist-core zeitgeist-datahub

echo "[4/6] Installing Server Utilities..."
# Ensure we have the standard server tools
apt-get update
apt-get install -y ubuntu-server

# Ensure network manager is configured or replaced by netplan/networkd if needed
# (Ubuntu Server uses netplan by default, which Desktop also uses, so this should be safe)

echo "[5/6] Cleaning up unused packages..."
apt-get autoremove --purge -y
apt-get clean

echo "[6/6] Setting default boot target to multi-user (CLI)..."
systemctl set-default multi-user.target

echo "=============================================================================="
echo " Conversion Complete."
echo " Please reboot the system to apply all changes."
echo " Recommended: Check your network configuration (ip a) before rebooting."
echo " Reboot command: reboot"
echo "=============================================================================="
