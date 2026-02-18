#!/bin/bash

# https://github.com/vercel-labs

# https://skills.sh/
# https://github.com/vercel-labs/skills
npx skills -h

# https://github.com/vercel-labs/just-bash
# https://justbash.dev/
npm install -g just-bash@latest


# list added to opencode and trae-cn using copy to all agents

npx skills add https://github.com/anthropics/skills -a opencode -a trae-cn -g
npx skills add https://github.com/vercel-labs/skills --skill find-skills -a opencode -a trae-cn -g
npx skills add https://github.com/vercel-labs/agent-skills -a opencode -a trae-cn -g
npx skills add https://github.com/wshobson/agents --skill python-code-style -a opencode -a trae-cn -g
npx skills add https://github.com/affaan-m/everything-claude-code -a opencode -a trae-cn -g
npx skills add https://github.com/forrestchang/andrej-karpathy-skills --skill karpathy-guidelines -a opencode -a trae-cn -g
npx skills add https://github.com/199-biotechnologies/claude-deep-research-skill --skill deep-research -a opencode -a trae-cn -g 
npx skills add https://github.com/luwill/research-skills -a opencode -a trae-cn -g
npx skills add https://github.com/ovachiever/droid-tings --skill reportlab -a opencode -a trae-cn -g
npx skills add https://github.com/obra/superpowers -a opencode -a trae-cn -g

