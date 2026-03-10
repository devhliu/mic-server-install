# step99_update_ubuntu.sh — Update Ubuntu and Install AI Development Tools

## Overview
This script updates the Ubuntu system and installs essential AI development tools including:

- **opencode-ai**: AI-powered code generation and assistance tool
- **codebuddy-code**: Tencent AI's code assistant tool  
- **GitHub Copilot CLI**: Command-line interface for GitHub Copilot

The script supports three modes:

- `all` (default): Update system and install AI tools in one run
- `update`: Only update system packages (apt, conda, etc.)
- `install_tools`: Only install AI development tools

## Prerequisites
- Root privileges (run with `sudo`)
- Node.js and npm must be installed (run `step02_install_node.sh` first)
- Internet connection for downloading packages

## Usage
```bash
# End-to-end (update system + install tools)
sudo bash step99_update_ubuntu.sh

# Explicitly run both
sudo bash step99_update_ubuntu.sh all

# Only update system packages
sudo bash step99_update_ubuntu.sh update

# Only install AI development tools
sudo bash step99_update_ubuntu.sh install_tools
```

## What the Script Does

### 1. System Update Phase
- Updates package lists: `sudo apt update`
- Upgrades installed packages: `sudo apt upgrade -y`
- Cleans up unnecessary packages: `sudo apt autoremove -y`
- Clears package cache: `sudo apt autoclean`

### 2. AI Tools Installation Phase
- Verifies Node.js and npm installation
- Installs global npm packages:
  - `opencode-ai@latest`
  - `@tencent-ai/codebuddy-code@latest`
  - `@github/copilot@latest`
- Verifies successful installation of each tool

## Required Dependencies

### Node.js and npm
This script requires Node.js and npm to be installed first. Run:
```bash
sudo bash step02_install_node.sh
```

Expected versions (minimum):
- Node.js: v16.0.0 or later
- npm: 7.0.0 or later

## Tool Descriptions

### opencode-ai
AI-powered code generation tool that provides intelligent code suggestions and completions.

**Usage examples:**
```bash
opencode-ai --help
```

### codebuddy-code
Tencent AI's code assistant tool for AI-powered development workflows.

**Usage examples:**
```bash
codebuddy-code --help
```

### GitHub Copilot CLI
Command-line interface for GitHub Copilot, enabling AI-assisted coding from the terminal.

**Usage examples:**
```bash
github-copilot-cli --help
# Or try individual commands:
copilot-complete "function that calculates fibonacci"
```

## Verification

After running the script, verify the installations:

```bash
# Check system update
lsb_release -a

# Check Node.js/npm versions
node -v
npm -v

# Check AI tools
which opencode-ai
which codebuddy-code
which github-copilot-cli

# Test tool functionality
opencode-ai --version
codebuddy-code --version
github-copilot-cli --version
```

## Troubleshooting

### Node.js Not Found
If you see "Error: Node.js is not installed":
```bash
# Install Node.js first
sudo bash step02_install_node.sh

# Then run this script
sudo bash step99_update_ubuntu.sh
```

### Permission Errors
If you encounter permission errors during npm installations:
```bash
# Ensure you're running with sudo
sudo bash step99_update_ubuntu.sh

# Check npm global install permissions
npm config get prefix
```

### Network Issues
If downloads fail due to network issues:
```bash
# Check internet connection
ping -c 3 google.com

# Try using a different network or VPN
# Retry the script
sudo bash step99_update_ubuntu.sh install_tools
```

### Tool Command Not Found
If tools are installed but not found in PATH:
```bash
# Check npm global bin directory
npm config get prefix

# Add to PATH if needed (usually /usr/local/bin)
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Uninstalling Tools

To remove individual tools:
```bash
# Uninstall opencode-ai
sudo npm uninstall -g opencode-ai

# Uninstall codebuddy-code
sudo npm uninstall -g @tencent-ai/codebuddy-code

# Uninstall GitHub Copilot CLI
sudo npm uninstall -g @github/copilot
```

To remove all tools:
```bash
sudo npm uninstall -g opencode-ai @tencent-ai/codebuddy-code @github/copilot
```

## Version Management

### Updating Tools
To update to the latest versions:
```bash
# Update all tools
sudo bash step99_update_ubuntu.sh install_tools

# Or update individually
sudo npm update -g opencode-ai
sudo npm update -g @tencent-ai/codebuddy-code
sudo npm update -g @github/copilot
```

### Specific Versions
To install specific versions, edit the version variables in the script:
```bash
# In step99_update_ubuntu.sh, modify:
OPENCODE_AI_VERSION="1.2.3"
CODEBUDDY_CODE_VERSION="2.0.1"
COPILOT_CLI_VERSION="1.5.0"
```

## Integration with Other Scripts

This script is designed to work with the existing installation sequence:

1. `step02_install_node.sh` - Install Node.js (required dependency)
2. `step99_update_ubuntu.sh` - Update system and install AI tools
3. Other specialized installation scripts as needed

## Security Considerations

- All tools are installed globally with `sudo`
- Ensure you trust the npm packages being installed
- Review the tools' permissions and access requirements
- Consider using version pinning for production environments

## Support

For issues with this script, check:
- Node.js installation: `step02_install_node_README.md`
- Individual tool documentation
- npm package pages for each tool

## Changelog

- **Initial version**: Basic system update and AI tool installation
- Supports three operation modes for flexibility
- Includes comprehensive verification and error handling