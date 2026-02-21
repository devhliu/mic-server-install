# Install VibeCoding Skills

This script installs various AI agent skills using the `skills` CLI tool. These skills enhance the capabilities of AI coding assistants.

## Overview of Changes
The script performs the following actions:
1.  **Installs Base Tools**: Installs `just-bash` globally.
2.  **Adds Skills**: Uses `npx skills add` to register skills for `opencode` and `trae-cn` agents.
    - Skills included: `find-skills`, `agent-skills`, `python-code-style`, `everything-claude-code`, `karpathy-guidelines`, `deep-research`, `research-skills`, `reportlab`, `superpowers`.

## Prerequisites
- **Node.js and npm**: Must be installed.
- **Network Connection**: Required to fetch skills from GitHub.

## Usage

### 1. Make the Script Executable
```bash
chmod +x step05_install_vibecoding_skills.sh
```

### 2. Run the Script
```bash
./step05_install_vibecoding_skills.sh
```

### 3. Verify
Check installed skills:
```bash
npx skills list
```
