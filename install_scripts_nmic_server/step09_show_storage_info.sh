#!/bin/bash

# Check if folder is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

FOLDER="$1"

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
    echo "Error: Directory '$FOLDER' not found."
    exit 1
fi

echo "--- Block Devices (Physical Disks and Partitions) ---"
# lsblk: List block devices
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL
echo ""

echo "--- Disk Space Usage (Mounted Filesystems) ---"
# df: Report file system disk space usage
df -h -x tmpfs -x devtmpfs
echo ""

echo "--- Disk Hardware Info (Requires sudo for full details) ---"
if [ "$EUID" -eq 0 ]; then
    fdisk -l | grep '^Disk /dev/'
else
    echo "Note: Run with sudo to see full partition table details from fdisk."
fi
echo ""

# Show Folder Information Header
echo "--- Folder Contents Information ---"
# Name: 50 chars, Size: 10 chars, Creator: 15 chars, Power: 15 chars
printf "%-50s %-10s %-15s %-15s\n" "Name" "Size(MB)" "Creator" "Power"
printf "%-50s %-10s %-15s %-15s\n" "----" "--------" "-------" "-----"

# Enable nullglob to handle empty directories gracefully
shopt -s nullglob

# Iterate over items in the folder
for item in "$FOLDER"/*; do
    if [ -e "$item" ]; then
        # Get the base name of the item
        name=$(basename "$item")
        
        # Get size in KB first
        size_kb=$(du -sk "$item" 2>/dev/null | cut -f1)
        
        # If size is empty (e.g. permission denied), set to 0
        if [ -z "$size_kb" ]; then
            size="?"
        else
            # Convert to MB with 2 decimal places
            size=$(awk "BEGIN {printf \"%.2f\", $size_kb/1024}")
        fi

        # Get owner (Creator)
        owner=$(stat -c "%U" "$item" 2>/dev/null)
        
        # Get permissions (Power)
        perms=$(stat -c "%A" "$item" 2>/dev/null)

        # Print the row
        printf "%-50s %-10s %-15s %-15s\n" "${name:0:49}" "$size" "$owner" "$perms"
    fi
done

shopt -u nullglob
