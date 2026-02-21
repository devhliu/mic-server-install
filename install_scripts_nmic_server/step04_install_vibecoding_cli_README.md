# Install VibeCoding CLI Tools

This script installs several global npm packages related to AI coding assistants and CLI tools.

## Overview of Changes
The script installs the following global npm packages:
- `@anthropic-ai/claude-code`: Claude Code CLI.
- `opencode-ai`: OpenCode AI CLI.
- `@tencent-ai/codebuddy-code`: CodeBuddy Code CLI.
- `@github/copilot`: GitHub Copilot CLI.

## Prerequisites
- **Node.js and npm**: Must be installed and available in the PATH.
- **Root Access**: Typically required for global npm installs (`-g`), unless npm is configured otherwise.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step04_install_vibecoding_cli.sh
```

### 2. Run the Script
```bash
sudo ./step04_install_vibecoding_cli.sh
```

### 3. Verify
Check if the tools are installed:
```bash
claude --version
opencode --version
codebuddy --version
github-copilot --version
```
(Note: binary names may vary slightly, check package documentation)
