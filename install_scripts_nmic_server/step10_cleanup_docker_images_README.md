# Cleanup Docker Images

This script provides an interactive utility to clean up Docker resources, including stopped containers, dangling images, unused networks, build cache, and unused volumes.

## Overview of Changes
The script performs the following actions:
1.  **Checks Docker Installation**: Verifies that Docker is installed and available.
2.  **Shows Current Usage**: Displays current Docker disk usage statistics.
3.  **Interactive Cleanup**: Provides step-by-step prompts to clean up:
    - **Stopped Containers**: Removes containers that are not currently running.
    - **Dangling Images**: Removes intermediate images tagged as `<none>` that are no longer referenced.
    - **Unused Networks**: Removes networks not used by at least one container.
    - **Build Cache**: Removes the build cache that is no longer in use.
    - **Unused Volumes**: Removes volumes not connected to any container (with per-volume confirmation).
4.  **Shows Final Usage**: Displays updated Docker disk usage after cleanup.

## Prerequisites
- **Docker Installation**: Docker must be installed and accessible via `docker` command.
- **Sudo Access**: Requires sudo privileges to perform Docker cleanup operations.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step10_cleanup_docker_images.sh
```

### 2. Run the Script
```bash
sudo ./step10_cleanup_docker_images.sh
```

### 3. Follow the Prompts
The script will guide you through five cleanup steps, asking for confirmation before each operation:

**Step 1/5**: Remove stopped containers
```
[1/5] Remove all stopped containers
      This will remove containers that are not currently running.
      Do you want to proceed? [y/N]:
```

**Step 2/5**: Remove dangling images
```
[2/5] Remove dangling images (tagged <none>)
      This removes intermediate images that are no longer referenced.
      Do you want to proceed? [y/N]:
```

**Step 3/5**: Remove unused networks
```
[3/5] Remove unused networks
      This removes networks not used by at least one container.
      Do you want to proceed? [y/N]:
```

**Step 4/5**: Remove build cache
```
[4/5] Remove build cache
      This removes the build cache that is no longer in use.
      Do you want to proceed? [y/N]:
```

**Step 5/5**: Remove unused volumes
```
[5/5] Remove unused volumes
      This will list all unused volumes and let you decide for each one.
      Do you want to proceed? [y/N]:
```

If you proceed, each unused volume will be shown with its mountpoint, and you can choose to delete or keep it individually:
```
      - Volume: my_volume_name
        Mountpoint: /var/lib/docker/volumes/my_volume_name/_data
        Delete this volume? [y/N]:
```

## What Gets Cleaned

### Stopped Containers
- Containers that have exited and are not currently running
- Does NOT affect running containers
- Frees up disk space used by container filesystems

### Dangling Images
- Images tagged as `<none>` (intermediate build images)
- Images that are not referenced by any container
- Does NOT remove images currently in use by containers

### Unused Networks
- Custom networks not connected to any containers
- Does NOT affect the default bridge network
- Frees up network resources

### Build Cache
- Cached layers from image builds that are no longer in use
- Includes cache from both Dockerfile builds and other build sources
- Frees up disk space used by build cache
- Does NOT affect cache currently being used by active builds

### Unused Volumes
- Volumes not connected to any container (dangling volumes)
- May contain database data, application data, or other persistent storage
- **⚠️ CAUTION**: Deleting volumes will permanently delete all data stored in them
- Each volume requires individual confirmation before deletion
- Shows volume name and mountpoint to help identify contents

## Safety Features
- **Interactive Confirmation**: Each cleanup step requires explicit confirmation
- **Safe Defaults**: Default response is 'N' (No) to prevent accidental cleanup
- **Progress Feedback**: Shows what's being cleaned and when it's complete
- **Before/After Comparison**: Displays disk usage before and after cleanup

## Notes
- This script is safe to run regularly to maintain Docker disk space
- Running containers are never affected
- Images in use by containers are protected
- The script only removes resources that are not actively used
- Build cache cleanup can significantly reduce disk usage, especially after many image builds
- **Volumes require extra caution**: Always verify volume contents before deletion, as they may contain important data
- For more aggressive cleanup, consider using `docker system prune -a` (not included in this script)
