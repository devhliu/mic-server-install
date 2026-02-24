# Show Folder Information

This script displays detailed information about files and directories in a specified folder, including size, owner, and permissions in a formatted table.

## Overview of Changes
The script performs the following actions:
1.  **Validates Input**: Checks if a folder path is provided and if the directory exists.
2.  **Displays Information**: Shows a formatted table with the following columns:
    - **Name**: File or directory name (truncated to 50 characters)
    - **Size**: Size in megabytes (MB) with 2 decimal places
    - **Creator**: Owner of the file/directory
    - **Power**: File permissions in human-readable format (e.g., `-rw-r--r--`)

## Prerequisites
- **Linux System**: Requires standard Linux utilities (`du`, `stat`, `awk`).
- **Read Permissions**: Must have read access to the target directory and its contents.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step09_show_folder_info.sh
```

### 2. Run the Script
```bash
./step09_show_folder_info.sh /path/to/folder
```

### 3. Examples

Show information about the current directory:
```bash
./step09_show_folder_info.sh .
```

Show information about a specific directory:
```bash
./step09_show_folder_info.sh /home/user/documents
```

Show information about system directories:
```bash
./step09_show_folder_info.sh /opt
./step09_show_folder_info.sh /var/log
```

## Output Format

The script displays a formatted table with the following columns:

| Name (50 chars) | Size(MB) | Creator (15 chars) | Power (15 chars) |
|-----------------|----------|--------------------|------------------|
| filename.txt    | 1.23     | username           | -rw-r--r--       |
| folder/         | 45.67    | username           | drwxr-xr-x       |

- **Name**: Truncated to 49 characters to maintain table alignment
- **Size**: Calculated from kilobytes to megabytes with 2 decimal places
- **Creator**: User who owns the file/directory
- **Power**: File permissions in symbolic notation

## Notes
- Files without read permissions will show `?` for size
- The script handles permission denied errors gracefully
- Empty directories are handled correctly (no rows displayed)
- Long filenames are truncated to maintain table formatting
