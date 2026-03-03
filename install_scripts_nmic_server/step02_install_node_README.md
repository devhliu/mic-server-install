# step02_install_node.sh — Install Node.js (Download + Install Combined)

## Overview
This script installs a specific Node.js version system-wide on Ubuntu by:

- Downloading the official Node.js tarball to `/tmp`.
- Installing to `/opt/node/v22.20.0` (default version set inside the script).
- Creating symlinks in `/usr/local/bin` for immediate availability of `node`, `npm`, and `npx`.
- Setting a persistent PATH via `/etc/profile.d/node-v22.20.0.sh`.
- Configuring the npm registry to `https://registry.npmmirror.com/` for faster access in China.
- Avoiding the `env: node: No such file or directory` error by invoking npm via `node`’s CLI directly during configuration.

The script supports three modes:

- `all` (default): Download and install in one run.
- `download`: Only download the Node.js archive to `/tmp`.
- `install`: Install Node.js, automatically downloading the archive if missing.

## Prerequisites
- Root privileges (run with `sudo`).
- Either `curl` or `wget` available.

## Usage
```bash
# End-to-end (download + install)
sudo bash step02_install_node.sh

# Explicitly run both
sudo bash step02_install_node.sh all

# Only download
sudo bash step02_install_node.sh download

# Only install (auto-downloads if needed)
sudo bash step02_install_node.sh install
```

## What the Script Does
1. Downloads `node-v22.20.0-linux-x64.tar.xz` to `/tmp`.
2. Extracts and installs to `/opt/node/v22.20.0`.
3. Creates symlinks for immediate system-wide access:
   - `/usr/local/bin/node` → `/opt/node/v22.20.0/bin/node`
   - `/usr/local/bin/npm`  → `/opt/node/v22.20.0/bin/npm`
   - `/usr/local/bin/npx`  → `/opt/node/v22.20.0/bin/npx`
4. Writes `/etc/profile.d/node-v22.20.0.sh` to persist PATH changes for future login shells.
5. Configures the npm registry to `https://registry.npmmirror.com/` by invoking:
   - `node /opt/node/v22.20.0/lib/node_modules/npm/bin/npm-cli.js config set registry ...`
6. Verifies versions for `node`, `npm`, and `npx`. If run via `sudo`, it also verifies for the original `SUDO_USER` when possible.

## Immediate Availability
Because the script creates symlinks in `/usr/local/bin`, `node`, `npm`, and `npx` are available immediately for all users whose PATH includes `/usr/local/bin`.

To check:
```bash
which node npm npx
node -v
npm -v
npx -v
```

If commands are still not found for your user, ensure `/usr/local/bin` is in your PATH:
```bash
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Log in again or start a new shell to load `/etc/profile.d/node-v22.20.0.sh` if desired.

## Changing the Node.js Version
Edit the `node_version` variable near the top of `step02_install_node.sh`. For example:
```bash
node_version="v22.20.0"
```
Re-run the script. New symlinks and a new `/etc/profile.d/node-<version>.sh` will be created for the chosen version.

## Switching Back to the Default npm Registry
If you prefer the official npm registry:
```bash
npm config set registry https://registry.npmjs.org/ --global
```

## Troubleshooting
- `env: node: No such file or directory` during npm configuration:
  - The script avoids this by calling `npm-cli.js` through `node` directly. If you see this error later, ensure `/usr/local/bin/node` exists and points to the correct binary.
- Commands not found for a specific user:
  - Make sure `/usr/local/bin` is in that user’s PATH (see “Immediate Availability”).
  - Open a new shell to apply PATH changes from `/etc/profile.d/`.

## Uninstall
To remove this Node.js installation (example for v22.20.0):
```bash
sudo rm -rf /opt/node/v22.20.0
sudo rm -f /etc/profile.d/node-v22.20.0.sh
sudo rm -f /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx
hash -r
```

## Verification
```bash
node -v    # Expect v22.20.0
npm -v     # Example: 10.x
npx -v     # Example: 10.x
```
