#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name>"
  echo ""
  echo "Stops all running agents for the specified company."
  echo "Agent tmux panes are closed, but roster.json status is preserved."
  echo "Use 'start.sh' to relaunch all active agents."
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
  echo "Error: tmux is not installed."
  exit 1
fi

if [[ -z "${TMUX:-}" ]]; then
  echo "Error: Not inside a tmux session."
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
  exit 0
fi

echo "=== Stopping company '$COMPANY_NAME' ==="

# Find and kill tmux panes whose command contains the agent directory path
KILLED=0

# Get all panes across all windows in current session
PANES=$(tmux list-panes -s -F '#{pane_id} #{pane_current_path}' 2>/dev/null || true)

while IFS= read -r AGENT_NAME; do
  AGENT_DIR="$COMPANY_DIR/agents/$AGENT_NAME"

  # Find panes with the agent's directory as their current path
  while IFS= read -r PANE_LINE; do
    [[ -z "$PANE_LINE" ]] && continue
    PANE_ID=$(echo "$PANE_LINE" | awk '{print $1}')
    PANE_PATH=$(echo "$PANE_LINE" | awk '{print $2}')

    if [[ "$PANE_PATH" == "$AGENT_DIR" || "$PANE_PATH" == "$AGENT_DIR/"* ]]; then
      tmux kill-pane -t "$PANE_ID" 2>/dev/null && KILLED=$((KILLED + 1))
      echo "  STOPPED: $AGENT_NAME (pane $PANE_ID)"
    fi
  done <<< "$PANES"
done <<< "$ACTIVE_AGENTS"

echo ""
echo "=== Company '$COMPANY_NAME' stopped ==="
echo "  Panes closed: $KILLED"
echo "  Roster status: preserved (active agents remain 'active')"
echo "  To restart: bash $AGENTLATTICE_ROOT/scripts/start.sh $COMPANY_NAME"
