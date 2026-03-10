#!/usr/bin/env bash
# step99_update_ubuntu.sh - Update Ubuntu system and install AI development tools
# Usage: sudo bash step99_update_ubuntu.sh [all|update|install_tools]
#   all          - Update system and install tools (default)
#   update       - Only update system packages
#   install_tools - Only install AI development tools
set -euo pipefail

# Tool versions
OPENCODE_AI_VERSION="latest"
CODEBUDDY_CODE_VERSION="latest"
COPILOT_CLI_VERSION="latest"

usage() {
  echo "Usage: $0 [all|update|install_tools]"
  echo "  all          - Update system and install AI development tools (default)"
  echo "  update       - Only update system packages"
  echo "  install_tools - Only install AI development tools"
  exit 1
}

update_system() {
  echo "Updating Ubuntu system packages..."
  
  # Update package lists
  sudo apt update
  
  # Upgrade installed packages
  sudo apt upgrade -y
  
  # Update apt packages
  sudo apt update && sudo apt upgrade -y
  
  # Clean up
  sudo apt autoremove -y
  sudo apt autoclean
  
  echo "System update completed successfully."
}

check_node_installation() {
  echo "Checking Node.js installation..."
  
  if ! command -v node >/dev/null 2>&1; then
    echo "Error: Node.js is not installed. Please run step02_install_node.sh first."
    exit 1
  fi
  
  if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is not installed. Please run step02_install_node.sh first."
    exit 1
  fi
  
  echo "Node.js version: $(node -v)"
  echo "npm version: $(npm -v)"
  
  if command -v npx >/dev/null 2>&1; then
    echo "npx version: $(npx -v)"
  fi
}

install_ai_tools() {
  echo "Installing AI development tools..."
  
  # Check Node.js installation first
  check_node_installation
  
  # Install opencode-ai
  echo "Installing opencode-ai@${OPENCODE_AI_VERSION}..."
  sudo npm install -g opencode-ai@${OPENCODE_AI_VERSION}
  
  # Install codebuddy-code
  echo "Installing @tencent-ai/codebuddy-code@${CODEBUDDY_CODE_VERSION}..."
  sudo npm install -g @tencent-ai/codebuddy-code@${CODEBUDDY_CODE_VERSION}
  
  # Install GitHub Copilot CLI
  echo "Installing @github/copilot@${COPILOT_CLI_VERSION}..."
  sudo npm install -g @github/copilot@${COPILOT_CLI_VERSION}
  
  # Verify installations
  echo "Verifying tool installations..."
  
  if command -v opencode-ai >/dev/null 2>&1; then
    echo "✓ opencode-ai installed successfully"
  else
    echo "✗ opencode-ai installation may have failed"
  fi
  
  if command -v codebuddy-code >/dev/null 2>&1; then
    echo "✓ codebuddy-code installed successfully"
  else
    echo "✗ codebuddy-code installation may have failed"
  fi
  
  if command -v github-copilot-cli >/dev/null 2>&1; then
    echo "✓ GitHub Copilot CLI installed successfully"
  else
    echo "✗ GitHub Copilot CLI installation may have failed"
  fi
  
  echo "AI development tools installation completed."
}

case "${1:-}" in
  all|"")
    update_system
    install_ai_tools
    ;;
  update)
    update_system
    ;;
  install_tools)
    install_ai_tools
    ;;
  *)
    usage
    ;;
esac