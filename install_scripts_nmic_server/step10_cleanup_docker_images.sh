#!/bin/bash

# Function to print section headers
print_header() {
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    exit 1
fi

print_header "Docker Cleanup Utility"
echo "Current Docker Disk Usage:"
sudo docker system df
echo "============================================================"

# 1. Remove Stopped Containers
echo ""
echo "[1/5] Remove all stopped containers"
echo "      This will remove containers that are not currently running."
read -p "      Do you want to proceed? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "      Removing stopped containers..."
    sudo docker container prune -f
    echo "      Done."
else
    echo "      Skipping."
fi

# 2. Remove Dangling Images (Dirty)
echo ""
echo "[2/5] Remove dangling images (tagged <none>)"
echo "      This removes intermediate images that are no longer referenced."
read -p "      Do you want to proceed? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "      Removing dangling images..."
    sudo docker image prune -f
    echo "      Done."
else
    echo "      Skipping."
fi

# 3. Remove Unused Networks
echo ""
echo "[3/5] Remove unused networks"
echo "      This removes networks not used by at least one container."
read -p "      Do you want to proceed? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "      Removing unused networks..."
    sudo docker network prune -f
    echo "      Done."
else
    echo "      Skipping."
fi

# 4. Remove Build Cache
echo ""
echo "[4/5] Remove build cache"
echo "      This removes the build cache that is no longer in use."
read -p "      Do you want to proceed? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "      Removing build cache..."
    sudo docker builder prune -f
    echo "      Done."
else
    echo "      Skipping."
fi

# 5. Remove Unused Volumes (Interactive per volume)
echo ""
echo "[5/5] Remove unused volumes"
echo "      This will list all unused volumes and let you decide for each one."
read -p "      Do you want to proceed? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    unused_volumes=$(sudo docker volume ls -q --filter "dangling=true")
    if [ -z "$unused_volumes" ]; then
        echo "      No unused volumes found."
    else
        echo "      Found the following unused volumes:"
        echo ""
        for vol in $unused_volumes; do
            vol_info=$(sudo docker volume inspect "$vol" --format '{{.Mountpoint}}' 2>/dev/null)
            echo "      - Volume: $vol"
            echo "        Mountpoint: $vol_info"
            read -p "        Delete this volume? [y/N]: " vol_choice
            if [[ "$vol_choice" =~ ^[Yy]$ ]]; then
                sudo docker volume rm "$vol"
                echo "        Deleted: $vol"
            else
                echo "        Kept: $vol"
            fi
            echo ""
        done
    fi
    echo "      Done."
else
    echo "      Skipping."
fi

echo ""
print_header "Cleanup Complete"
echo "New Docker Disk Usage:"
sudo docker system df
