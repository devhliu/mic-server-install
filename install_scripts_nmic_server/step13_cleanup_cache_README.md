# Step 13: Cache Cleanup Script Documentation

## Overview

The `step13_cleanup_cache.sh` script is a comprehensive cache cleaning utility designed to remove various cache files and directories from a specified root folder. This script is part of the MIC server installation process and helps maintain a clean and efficient file system by removing unnecessary cache files, build artifacts, and temporary files.

## Features

- **Recursive Cleaning**: Scans and cleans cache files and directories throughout the entire folder tree
- **Dry-Run Mode**: Preview what would be deleted without actually removing files
- **Configurable Patterns**: Supports custom cache patterns for targeted cleaning
- **Safe Deletion**: Includes confirmation prompts before deletion
- **Progress Reporting**: Provides detailed feedback during the cleaning process
- **Summary Statistics**: Reports the number of files/directories removed and space freed
- **Error Handling**: Gracefully handles errors and reports them in the summary

## Supported Cache Types

### Python Cache
- `__pycache__` directories
- `.pytest_cache` directories
- `*.pyc`, `*.pyo`, `*.pyd` files
- `.mypy_cache`, `.ruff_cache` directories
- `.coverage` files
- `.tox`, `.nox` directories

### Build Artifacts
- `build` and `dist` directories
- `*.egg-info` directories
- `*.egg` files
- `.eggs` directories
- `MANIFEST` and `MANIFEST.in` files

### IDE and Editor Cache
- `.vscode` directories
- `.idea` directories
- `*.swp`, `*.swo` files (Vim swap files)
- `*.tmp` files

### Package Manager Cache
- `node_modules` directories
- `.npm` directories
- `.cache` directories

### OS and System Cache
- `.DS_Store` files (macOS)
- `Thumbs.db` files (Windows)
- `*.log` files

### Log Directories
- `logs` directories
- `_logs` directories
- `logs_*` pattern directories
- `*_logs` pattern directories

## Usage

### Basic Syntax

```bash
./step13_cleanup_cache.sh [OPTIONS] ROOT_FOLDER
```

### Required Arguments

- `ROOT_FOLDER`: The root directory to clean (must be a valid directory path)

### Optional Arguments

- `-h, --help`: Display help message and exit
- `-d, --dry-run`: Preview what would be removed without actually deleting
- `-p, --patterns`: Comma-separated list of custom cache patterns
- `-l, --list-patterns`: Show all available cache patterns and exit
- `-v, --version`: Display version information and exit

## Examples

### Basic Cleaning

Clean a project directory with default patterns:

```bash
./step13_cleanup_cache.sh /path/to/project
```

### Dry-Run Mode

Preview what would be removed without deleting:

```bash
./step13_cleanup_cache.sh /path/to/project --dry-run
```

### Custom Patterns

Clean specific cache types:

```bash
./step13_cleanup_cache.sh /path/to/project --patterns "__pycache__,.pytest_cache,*.pyc"
```

### Combined Options

Use dry-run with custom patterns:

```bash
./step13_cleanup_cache.sh /path/to/project -d -p "*.log,*.tmp"
```

### List Available Patterns

View all supported cache patterns:

```bash
./step13_cleanup_cache.sh --list-patterns
```

## Workflow

1. **Initialization**: The script validates the root folder path and initializes statistics counters
2. **Pattern Matching**: Scans the directory tree for files and directories matching cache patterns
3. **Preview**: Displays found cache items (limited to first 10 items of each type)
4. **Confirmation**: Prompts for user confirmation before deletion (skipped in dry-run mode)
5. **Deletion**: Removes matched files and directories
6. **Summary**: Reports statistics including files/directories removed and space freed

## Output

### During Execution

The script provides real-time feedback:

- 🔍 Searching indicator
- 📄 List of files to remove
- 📁 List of directories to remove
- 🗑️ Removal progress
- ❌ Error messages (if any)

### Summary Report

After completion, the script displays:

```
📊 Cleaning Summary:
   - Files removed: [count]
   - Directories removed: [count]
   - Total items: [count]
   - Space freed: [size] MB
   - Errors encountered: [count]
```

## Safety Features

1. **Confirmation Prompt**: Requires explicit user confirmation before deletion
2. **Dry-Run Mode**: Allows safe preview of what would be deleted
3. **Error Handling**: Continues operation even if individual files fail to delete
4. **Signal Handling**: Gracefully handles interrupt signals (Ctrl+C)
5. **Path Validation**: Verifies the root folder exists and is a directory

## Pattern Matching

### File Patterns

File patterns support wildcards:
- `*.pyc` - matches all files ending with `.pyc`
- `*.log` - matches all files ending with `.log`
- Exact names like `MANIFEST` match files with that exact name

### Directory Patterns

Directory patterns can be:
- Exact names: `__pycache__`, `node_modules`
- Prefix wildcards: `logs_*` matches directories starting with `logs_`
- Suffix wildcards: `*_logs` matches directories ending with `_logs`

## Exit Codes

- `0`: Success
- `1`: Error (invalid arguments, directory not found, operation cancelled, etc.)

## Dependencies

The script requires the following standard Unix utilities:
- `bash` (version 4.0 or higher recommended)
- `find` - for directory traversal
- `stat` or `du` - for size calculation
- `bc` - for size formatting (optional)
- `mktemp` - for temporary file creation

## Integration with MIC Server Installation

This script is designed to be run as Step 13 of the MIC server installation process. It helps clean up:

1. Installation artifacts
2. Build cache from compiled components
3. Temporary files created during installation
4. Log files generated during the installation process

### Typical Usage in Installation

```bash
# After completing previous installation steps
cd /opt/mic-server
./step13_cleanup_cache.sh /opt/mic-server

# Or with dry-run to preview first
./step13_cleanup_cache.sh /opt/mic-server --dry-run
```

## Best Practices

1. **Always Use Dry-Run First**: Preview the changes before actual deletion
2. **Run as Appropriate User**: Ensure you have necessary permissions to delete files
3. **Check Important Files**: Verify that important files aren't matched by cache patterns
4. **Regular Maintenance**: Run periodically to keep the system clean
5. **Backup Critical Data**: Always have backups before running cleanup scripts

## Troubleshooting

### Permission Denied Errors

If you encounter permission errors:
```bash
# Run with appropriate permissions
sudo ./step13_cleanup_cache.sh /path/to/directory
```

### Pattern Not Matching

If a pattern doesn't match expected files:
1. Use `--list-patterns` to verify available patterns
2. Check if the pattern syntax is correct
3. Use custom patterns with `-p` option

### Large Directories

For very large directory trees:
- The script may take longer to scan
- Consider running on subdirectories individually
- Use dry-run mode to estimate scope first

## Differences from Python Version

This Bash implementation provides equivalent functionality to the Python version with these considerations:

1. **Performance**: Bash version may be slower for very large directory trees
2. **Pattern Matching**: Uses shell pattern matching instead of Python's fnmatch
3. **Size Calculation**: Uses `du` command instead of Python's os.stat
4. **Dependencies**: Requires only standard Unix utilities, no Python installation needed

## Version History

- **v1.0.0**: Initial Bash implementation converted from Python script
  - All core features implemented
  - Pattern matching for files and directories
  - Dry-run mode
  - Summary statistics
  - Error handling

## Support

For issues or questions:
1. Check the script's help output: `./step13_cleanup_cache.sh --help`
2. Review the list of patterns: `./step13_cleanup_cache.sh --list-patterns`
3. Test with dry-run mode first
4. Check file permissions and ownership

## License

This script is part of the MIC server installation toolkit and follows the project's licensing terms.
