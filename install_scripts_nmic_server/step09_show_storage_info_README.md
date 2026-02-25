# Show Storage Information

This script displays comprehensive storage information, including physical disk details, partition usage, and detailed information about files and directories in a specified folder.

## Overview of Changes
The script performs the following actions:
1.  **Validates Input**: Checks if a folder path is provided and if the directory exists.
2.  **Shows Block Devices**: Lists physical disks and partitions using `lsblk`.
3.  **Shows Disk Space Usage**: Displays human-readable disk space usage for all mounted filesystems using `df -h`.
4.  **Shows Hardware Info**: Displays low-level disk hardware information (requires `sudo`).
5.  **Displays Folder Information**: Shows a formatted table for the specified folder with the following columns:
    - **Name**: File or directory name (truncated to 50 characters)
    - **Size**: Size in megabytes (MB) with 2 decimal places
    - **Creator**: Owner of the file/directory
    - **Power**: File permissions in human-readable format (e.g., `-rw-r--r--`)

## Prerequisites
- **Linux System**: Requires standard Linux utilities (`lsblk`, `df`, `du`, `stat`, `awk`, `fdisk`).
- **Read Permissions**: Must have read access to the target directory and its contents.
- **Root Access (Optional)**: `sudo` is required to see full partition table details from `fdisk`.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step09_show_storage_info.sh
```

### 2. Run the Script
```bash
./step09_show_storage_info.sh /path/to/folder
```

### 3. Examples

Show storage information and current directory details:
```bash
./step09_show_storage_info.sh .
```

Show storage information and a specific directory:
```bash
./step09_show_storage_info.sh /home/user/documents
```

## Output Format

The script displays three main sections:
1.  **Block Devices**: Output from `lsblk` showing the disk hierarchy.
2.  **Disk Space Usage**: Output from `df -h` for all mounted partitions.
3.  **Folder Contents**: A formatted table of the specified directory.

| Name (50 chars) | Size(MB) | Creator (15 chars) | Power (15 chars) |
|-----------------|----------|--------------------|------------------|
| filename.txt    | 1.23     | username           | -rw-r--r--       |
| folder/         | 45.67    | username           | drwxr-xr-x       |

## Notes
- Files without read permissions will show `?` for size
- The script handles permission denied errors gracefully
- Long filenames are truncated to maintain table formatting
