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

echo "Checking skills CLI..."
npx skills -h

echo "Installing just-bash..."
run_cmd "$USE_SUDO" npm install -g just-bash@latest

echo "Adding vibecoding skills..."
npx skills add https://github.com/anthropics/skills -a opencode -a trae-cn -g
npx skills add https://github.com/vercel-labs/skills --skill find-skills -a opencode -a trae-cn -g
npx skills add https://github.com/vercel-labs/agent-skills -a opencode -a trae-cn -g
npx skills add https://github.com/wshobson/agents --skill python-code-style -a opencode -a trae-cn -g
npx skills add https://github.com/affaan-m/everything-claude-code -a opencode -a trae-cn -g
npx skills add https://github.com/forrestchang/andrej-karpathy-skills --skill karpathy-guidelines -a opencode -a trae-cn -g
npx skills add https://github.com/199-biotechnologies/claude-deep-research-skill --skill deep-research -a opencode -a trae-cn -g 
npx skills add https://github.com/luwill/research-skills -a opencode -a trae-cn -g
npx skills add https://github.com/ovachiever/droid-tings --skill reportlab -a opencode -a trae-cn -g

echo ""
echo "Vibecoding skills installed successfully!"
