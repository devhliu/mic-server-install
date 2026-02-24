# Reinstall R Environment

This script installs R (CLI) and its development environment on Ubuntu 24.04 using the official CRAN repository.

## Overview of Changes
The script performs the following actions:
1.  **Checks Privileges**: Verifies the script is run with root/sudo privileges.
2.  **Updates System**: Updates existing package lists.
3.  **Installs Prerequisites**: Installs required packages (`software-properties-common`, `dirmngr`, `gnupg`, `wget`).
4.  **Imports CRAN GPG Key**: Downloads and installs the CRAN signing key for package verification.
5.  **Adds CRAN Repository**: Configures the CRAN repository for Ubuntu 24.04 (Noble).
6.  **Installs R**: Installs `r-base` and `r-base-dev` packages.
7.  **Installs Dependencies**: Installs common system libraries required for R packages (tidyverse, data.table, etc.).
8.  **Cleans Up**: Removes unnecessary apt cache.
9.  **Verifies Installation**: Displays the installed R version.

## Prerequisites
- **Operating System**: Ubuntu 24.04 (Noble Numbat)
- **Root Access**: Must be run with `sudo` or as root user
- **Internet Connection**: Required to download packages from CRAN repository

## Usage

### 1. Make the Script Executable
```bash
chmod +x step11_reinstall_r.sh
```

### 2. Run the Script
```bash
sudo ./step11_reinstall_r.sh
```

Or using bash:
```bash
sudo bash step11_reinstall_r.sh
```

## Installation Details

### R Version
- Installs the latest R 4.x series from CRAN
- Uses the `noble-cran40` repository for Ubuntu 24.04

### System Libraries Installed
The following development libraries are installed to support common R packages:

| Library | Purpose |
|---------|---------|
| `libcurl4-openssl-dev` | HTTP client support (httr, curl packages) |
| `libssl-dev` | SSL/TLS support (openssl package) |
| `libxml2-dev` | XML processing (xml2, rvest packages) |
| `libfontconfig1-dev` | Font configuration (ragg package) |
| `libharfbuzz-dev` | Text shaping (ragg, textshaping packages) |
| `libfribidi-dev` | Bidirectional text (ragg package) |
| `libfreetype6-dev` | Font rendering (ragg package) |
| `libpng-dev` | PNG image support |
| `libtiff5-dev` | TIFF image support |
| `libjpeg-dev` | JPEG image support |
| `libgit2-dev` | Git integration (git2r, gert packages) |
| `make` | Build tool |
| `cmake` | Build system |
| `git` | Version control |

## Output

The script provides colored output indicating progress:
- **Green**: Success messages and completion
- **Yellow**: Progress updates and ongoing operations
- **Red**: Error messages

Example output:
```
>>> Starting R Environment Installation for Ubuntu 24.04...
>>> Updating existing package lists...
>>> Installing prerequisites...
>>> Importing CRAN GPG Key...
>>> Adding CRAN Repository for Noble (24.04)...
>>> Updating package lists with new repository...
>>> Installing R Base and Dev packages...
>>> Installing common system libraries for R packages...
>>> Cleaning up apt cache...
>>> Installation Complete! Verifying R version...
R version 4.x.x (202x-xx-xx) -- "..."
>>> R environment is ready. Type 'R' to start.
```

## Notes
- The script uses `set -e` to exit immediately if any command fails
- GPG key is stored in `/etc/apt/keyrings/cran.gpg`
- Repository configuration is stored in `/etc/apt/sources.list.d/cran.list`
- After installation, start R by typing `R` in the terminal
- For package installation, use `install.packages("package_name")` within R
