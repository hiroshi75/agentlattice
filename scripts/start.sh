#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name>"
  echo ""
  echo "Starts all active agents for the specified company."
  echo "Reads roster.json and launches each agent with status 'active' in a tmux pane."
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

COMPANY_NAME="$1"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"
ROSTER_FILE="$COMPANY_DIR/org/roster.json"

# Validate company exists
if [[ ! -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' does not exist at $COMPANY_DIR"
  exit 1
fi

if [[ ! -f "$ROSTER_FILE" ]]; then
  echo "Error: Roster file not found at $ROSTER_FILE"
  exit 1
fi

# Check tmux is available
if ! command -v tmux &> /dev/null; then
  echo "Error: tmux is not installed. Install it with: brew install tmux"
  exit 1
fi

# Check we're inside a tmux session
if [[ -z "${TMUX:-}" ]]; then
  echo "Error: Not inside a tmux session. Start tmux first: tmux new -s agentlattice"
  exit 1
fi

# Get active agents from roster
ACTIVE_AGENTS=$(python3 -c "
import json
with open('$ROSTER_FILE') as f:
    roster = json.load(f)
agents = [a['name'] for a in roster.get('agents', []) if a.get('status') == 'active']
print('\n'.join(agents))
" 2>/dev/null)

if [[ -z "$ACTIVE_AGENTS" ]]; then
  echo "No active agents found in $ROSTER_FILE"
  echo "All agents may be suspended, or no agents have been hired yet."
  exit 0
fi

AGENT_COUNT=$(echo "$ACTIVE_AGENTS" | wc -l | tr -d ' ')
echo "=== Starting company '$COMPANY_NAME' ==="
echo "Active agents to launch: $AGENT_COUNT"
echo ""

LAUNCHED=0
SKIPPED=0

while IFS= read -r AGENT_NAME; do
  AGENT_DIR="$COMPANY_DIR/agents/$AGENT_NAME"

  if [[ ! -f "$AGENT_DIR/CLAUDE.md" ]]; then
    echo "  SKIP: $AGENT_NAME (no CLAUDE.md found at $AGENT_DIR)"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Use hire.sh to launch (handles tiled layout and max_panes_per_window)
  bash "$AGENTLATTICE_ROOT/scripts/hire.sh" "$COMPANY_NAME" "$AGENT_NAME" 2>/dev/null
  LAUNCHED=$((LAUNCHED + 1))
  echo "  OK: $AGENT_NAME"

  # Small delay to let tmux settle between pane creation
  sleep 0.5
done <<< "$ACTIVE_AGENTS"

echo ""
echo "=== Company '$COMPANY_NAME' started ==="
echo "  Launched: $LAUNCHED agents"
if [[ $SKIPPED -gt 0 ]]; then
  echo "  Skipped: $SKIPPED agents (missing CLAUDE.md)"
fi
echo "  Layout: tiled (max $(config_get 'max_panes_per_window' '4') panes per window)"
