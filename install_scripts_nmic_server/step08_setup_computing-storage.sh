#!/bin/bash

# Configuration
# Default IP addresses as requested
COMPUTING_SERVER_IP="<COMPUTING_SERVER_IP>"
DATA_SERVER_IP="<DATA_SERVER_IP>"

# Check if IPs are configured
if [[ "$COMPUTING_SERVER_IP" == "<COMPUTING_SERVER_IP>" ]] || [[ "$DATA_SERVER_IP" == "<DATA_SERVER_IP>" ]]; then
    echo "Error: Please update the COMPUTING_SERVER_IP and DATA_SERVER_IP variables in the script with the correct IP addresses."
    exit 1
fi

# Directories
DATA_DIR_COMPUTING_1="/data01"
DATA_DIR_COMPUTING_2="/data02"
DATA_DIR_DATA="/data"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root."
  exit 1
fi

echo "--------------------------------------------------------"
echo " Server Storage Setup Script"
echo "--------------------------------------------------------"
echo "Select the role for this machine:"
echo "1) Computing Server (IP: $COMPUTING_SERVER_IP)"
echo "   - Creates $DATA_DIR_COMPUTING_1, $DATA_DIR_COMPUTING_2"
echo "   - Mounts $DATA_SERVER_IP:$DATA_DIR_DATA to $DATA_DIR_COMPUTING_2"
echo ""
echo "2) Data Server (IP: $DATA_SERVER_IP)"
echo "   - Creates $DATA_DIR_DATA"
echo "   - Exports $DATA_DIR_DATA to $COMPUTING_SERVER_IP"
echo ""
read -p "Enter choice [1 or 2]: " server_role

if [ "$server_role" == "1" ]; then
    # ==========================================
    # Computing Server Configuration
    # ==========================================
    echo "Configuring Computing Server..."
    
    # 1. Install NFS Client
    echo "Installing nfs-common..."
    apt-get update -qq && apt-get install -y nfs-common
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install nfs-common."
        exit 1
    fi

    # 2. Create local directories
    echo "Creating directories..."
    mkdir -p "$DATA_DIR_COMPUTING_1"
    mkdir -p "$DATA_DIR_COMPUTING_2"
    
    # Set permissions (adjust as needed, 755 is safer than 777)
    chmod 755 "$DATA_DIR_COMPUTING_1"
    chmod 755 "$DATA_DIR_COMPUTING_2"

    # 3. Configure /etc/fstab for Auto-mounting
    # Options explanation:
    # - defaults: standard options (rw, suid, dev, exec, auto, nouser, async)
    # - nofail: do not fail boot if mount fails
    # - x-systemd.automount: mount on demand (access)
    # - _netdev: wait for network to be up
    MOUNT_OPTS="defaults,nofail,x-systemd.automount,_netdev"
    FSTAB_ENTRY="$DATA_SERVER_IP:$DATA_DIR_DATA $DATA_DIR_COMPUTING_2 nfs $MOUNT_OPTS 0 0"
    
    # Backup fstab
    cp /etc/fstab /etc/fstab.bak.$(date +%F_%T)

    # Remove existing entry for /data02 to avoid duplicates
    sed -i "\| $DATA_DIR_COMPUTING_2 |d" /etc/fstab
    
    echo "Adding mount entry to /etc/fstab..."
    echo "$FSTAB_ENTRY" >> /etc/fstab

    # 4. Reload systemd and attempt mount
    echo "Reloading systemd daemon..."
    systemctl daemon-reload
    systemctl restart remote-fs.target

    # 5. Check Mount Status
    echo "Checking mount status..."
    if mountpoint -q "$DATA_DIR_COMPUTING_2"; then
        echo "SUCCESS: $DATA_DIR_COMPUTING_2 is currently mounted."
    else
        echo "WARNING: $DATA_DIR_COMPUTING_2 is NOT mounted yet."
        echo "Note: It is configured to auto-mount when accessed or when the network is available."
        echo "You can try verifying connectivity to $DATA_SERVER_IP."
    fi

elif [ "$server_role" == "2" ]; then
    # ==========================================
    # Data Server Configuration
    # ==========================================
    echo "Configuring Data Server..."

    # 1. Install NFS Server
    echo "Installing nfs-kernel-server..."
    apt-get update -qq && apt-get install -y nfs-kernel-server
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install nfs-kernel-server."
        exit 1
    fi

    # 2. Create Data Directory
    echo "Creating directory $DATA_DIR_DATA..."
    mkdir -p "$DATA_DIR_DATA"
    chmod 755 "$DATA_DIR_DATA" 
    # Note: Ownership might need to be adjusted based on user needs, e.g., chown nobody:nogroup

    # 3. Configure /etc/exports
    # Options:
    # - rw: read-write
    # - sync: write changes to disk immediately
    # - no_subtree_check: improve reliability
    # - no_root_squash: allow root on client to write as root (optional, often needed for convenience)
    EXPORT_ENTRY="$DATA_DIR_DATA $COMPUTING_SERVER_IP(rw,sync,no_subtree_check,no_root_squash)"
    
    # Backup exports
    cp /etc/exports /etc/exports.bak.$(date +%F_%T)

    # Remove existing entry for this directory/IP combo to avoid duplicates
    # This regex is simple; purely appending is safer if not sure, but we want to update.
    # We'll just append and let exportfs warn/handle duplicates or clean up manually if needed.
    # A simple check:
    if grep -q "^$DATA_DIR_DATA" /etc/exports; then
        echo "Entry for $DATA_DIR_DATA exists in /etc/exports. Please verify manually if it needs updating."
        echo "Proposed entry: $EXPORT_ENTRY"
        # Uncomment to force update:
        # sed -i "\|^$DATA_DIR_DATA|d" /etc/exports
        # echo "$EXPORT_ENTRY" >> /etc/exports
    else
        echo "Adding entry to /etc/exports..."
        echo "$EXPORT_ENTRY" >> /etc/exports
    fi

    # 4. Apply Exports
    echo "Exporting file systems..."
    exportfs -ra
    systemctl restart nfs-kernel-server

    echo "SUCCESS: Data Server configured."
    echo "Directory $DATA_DIR_DATA is ready to be mounted by $COMPUTING_SERVER_IP."

else
    echo "Invalid option. Exiting."
    exit 1
fi
