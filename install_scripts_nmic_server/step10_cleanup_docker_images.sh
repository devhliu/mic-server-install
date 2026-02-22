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
echo "[1/3] Remove all stopped containers"
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
echo "[2/3] Remove dangling images (tagged <none>)"
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
echo "[3/3] Remove unused networks"
echo "      This removes networks not used by at least one container."
read -p "      Do you want to proceed? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "      Removing unused networks..."
    sudo docker network prune -f
    echo "      Done."
else
    echo "      Skipping."
fi

echo ""
print_header "Cleanup Complete"
echo "New Docker Disk Usage:"
sudo docker system df
