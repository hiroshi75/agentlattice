#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
ensure_home

usage() {
  echo "Usage: $0 <company-name>"
  echo ""
  echo "Initializes a new company with the standard AgentLattice directory structure."
  echo "Company name should be kebab-case (e.g., my-startup)."
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

COMPANY_NAME="$1"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"

if [[ -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' already exists at $COMPANY_DIR"
  exit 1
fi

# Create directory structure
mkdir -p "$COMPANY_DIR/org/knowledge" \
         "$COMPANY_DIR/org/channels" \
         "$COMPANY_DIR/org/tasks" \
         "$COMPANY_DIR/agents"

# Create default channels from config
python3 -c "
import json, os
config_path = '$AGENTLATTICE_CONFIG'
channels = ['general', 'shareholder']
if os.path.isfile(config_path):
    with open(config_path) as f:
        cfg = json.load(f)
    channels = cfg.get('default_channels', channels)
channels_dir = '$COMPANY_DIR/org/channels'
for ch in channels:
    open(os.path.join(channels_dir, ch + '.jsonl'), 'a').close()
    print(f'  Created channel: {ch}')
"

# Create other default files
echo '{"agents":[]}' > "$COMPANY_DIR/org/roster.json"
touch "$COMPANY_DIR/org/tasks/backlog.jsonl"
touch "$COMPANY_DIR/org/tasks/done.jsonl"

echo "Company '$COMPANY_NAME' initialized successfully at $COMPANY_DIR"
echo ""
echo "Directory structure:"
echo "  $COMPANY_DIR/"
echo "  ├── org/"
echo "  │   ├── knowledge/"
echo "  │   ├── channels/"
echo "  │   │   ├── general.jsonl"
echo "  │   │   └── shareholder.jsonl"
echo "  │   ├── tasks/"
echo "  │   │   ├── backlog.jsonl"
echo "  │   │   └── done.jsonl"
echo "  │   └── roster.json"
echo "  └── agents/"
echo ""
echo "Next step: cd $COMPANY_DIR && claude"
