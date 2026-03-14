#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name>"
  echo ""
  echo "Shows agent activity status for the specified company."
  echo "Displays last activity time, message counts, and workspace file counts."
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

COMPANY_NAME="$1"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"

if [[ ! -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' does not exist at $COMPANY_DIR"
  exit 1
fi

ROSTER="$COMPANY_DIR/org/roster.json"
CHANNELS_DIR="$COMPANY_DIR/org/channels"

if [[ ! -f "$ROSTER" ]]; then
  echo "Error: No roster.json found at $ROSTER"
  exit 1
fi

echo "=== AgentLattice Status: $COMPANY_NAME ==="
echo ""

python3 -c "
import json
import os
import glob
from datetime import datetime, timezone

company_dir = '$COMPANY_DIR'
roster_path = '$ROSTER'
channels_dir = '$CHANNELS_DIR'

# Load roster
with open(roster_path) as f:
    roster = json.load(f)

# Load all channel messages
all_messages = []
if os.path.isdir(channels_dir):
    for jsonl_file in glob.glob(os.path.join(channels_dir, '*.jsonl')):
        basename = os.path.basename(jsonl_file)
        if basename.startswith('_archived_'):
            continue
        with open(jsonl_file) as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        all_messages.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass

# Compute per-agent stats
print(f\"{'Name':<20} {'Status':<12} {'Messages':<10} {'Last Active':<22} {'Workspace Files':<15}\")
print('-' * 79)

agents = roster.get('agents', [])
if not agents:
    print('No agents registered.')
else:
    for agent in agents:
        name = agent['name']
        display = agent.get('display_name', name)
        status = agent.get('status', 'unknown')

        # Count messages from this agent
        agent_msgs = [m for m in all_messages if m.get('from') == name]
        msg_count = len(agent_msgs)

        # Find last activity
        last_active = '-'
        if agent_msgs:
            sorted_msgs = sorted(agent_msgs, key=lambda m: m.get('ts', ''))
            last_ts = sorted_msgs[-1].get('ts', '')
            if last_ts:
                try:
                    dt = datetime.fromisoformat(last_ts.replace('Z', '+00:00'))
                    last_active = dt.strftime('%Y-%m-%d %H:%M')
                except:
                    last_active = last_ts[:16]

        # Count workspace files
        workspace = os.path.join(company_dir, 'agents', name, 'workspace')
        ws_files = 0
        if os.path.isdir(workspace):
            for _, _, files in os.walk(workspace):
                ws_files += len(files)

        status_display = status
        label = f'{display} ({name})'
        print(f'{label:<20} {status_display:<12} {msg_count:<10} {last_active:<22} {ws_files:<15}')

# Channel summary
print()
print('=== Channel Summary ===')
print()
channel_stats = {}
if os.path.isdir(channels_dir):
    for jsonl_file in sorted(glob.glob(os.path.join(channels_dir, '*.jsonl'))):
        basename = os.path.basename(jsonl_file)
        if basename.startswith('_archived_'):
            continue
        ch_name = basename.replace('.jsonl', '')
        count = 0
        with open(jsonl_file) as f:
            for line in f:
                if line.strip():
                    count += 1
        print(f'  #{ch_name}: {count} messages')

# Knowledge files
knowledge_dir = os.path.join(company_dir, 'org', 'knowledge')
if os.path.isdir(knowledge_dir):
    knowledge_files = [f for f in os.listdir(knowledge_dir) if f.endswith('.md')]
    print()
    print(f'=== Shared Knowledge: {len(knowledge_files)} files ===')
"
