#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/install_utils.sh"

npm_global_dir=$(npm config get prefix 2>/dev/null || echo "/usr/local")

USE_SUDO="false"
if needs_sudo "$npm_global_dir"; then
  USE_SUDO="true"
  echo "npm global directory ${npm_global_dir} requires sudo."
else
  echo "npm global directory ${npm_global_dir} does not require sudo."
fi

echo "Installing AI coding tools..."

echo "Installing claude-code..."
run_cmd "$USE_SUDO" npm install -g @anthropic-ai/claude-code@latest

echo "Installing opencode-ai..."
run_cmd "$USE_SUDO" npm i -g opencode-ai@latest

echo "Installing codebuddy-code..."
run_cmd "$USE_SUDO" npm install -g @tencent-ai/codebuddy-code@latest

echo "Installing GitHub Copilot CLI..."
run_cmd "$USE_SUDO" npm install -g @github/copilot@latest

echo ""
echo "AI coding tools installed successfully!"
echo "Installed packages:"
echo "  - @anthropic-ai/claude-code"
echo "  - opencode-ai"
echo "  - @tencent-ai/codebuddy-code"
echo "  - @github/copilot"

if [ "$USE_SUDO" = "true" ]; then
  echo ""
  echo "Note: Packages were installed system-wide."
else
  echo ""
  echo "Note: Packages were installed in user directory."
fi
