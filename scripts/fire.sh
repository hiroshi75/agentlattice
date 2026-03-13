#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name> <agent-name>"
  echo ""
  echo "Suspends an agent by updating their status in roster.json."
  echo "You must manually stop /loop in the agent's tmux pane."
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

COMPANY_NAME="$1"
AGENT_NAME="$2"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"
ROSTER_FILE="$COMPANY_DIR/org/roster.json"

# Validate company exists
if [[ ! -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' does not exist at $COMPANY_DIR"
  exit 1
fi

# Validate roster exists
if [[ ! -f "$ROSTER_FILE" ]]; then
  echo "Error: Roster file not found at $ROSTER_FILE"
  exit 1
fi

# Check agent exists in roster
if ! python3 -c "
import json, sys
with open('$ROSTER_FILE') as f:
    roster = json.load(f)
found = any(a['name'] == '$AGENT_NAME' for a in roster['agents'])
sys.exit(0 if found else 1)
" 2>/dev/null; then
  echo "Error: Agent '$AGENT_NAME' not found in roster for company '$COMPANY_NAME'."
  exit 1
fi

# Update roster.json: set agent status to suspended
python3 -c "
import json
roster_path = '$ROSTER_FILE'
with open(roster_path) as f:
    roster = json.load(f)
for agent in roster['agents']:
    if agent['name'] == '$AGENT_NAME':
        agent['status'] = 'suspended'
        break
with open(roster_path, 'w') as f:
    json.dump(roster, f, indent=2, ensure_ascii=False)
"

echo "Agent '$AGENT_NAME' has been suspended in company '$COMPANY_NAME'."
echo "roster.json updated: status -> \"suspended\""
echo ""
echo "IMPORTANT: Please manually stop /loop in the agent's tmux pane."
echo "Find the pane and type Ctrl+C or close it manually."
