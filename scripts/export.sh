#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name> [output-dir]"
  echo ""
  echo "Exports a company to a portable archive (.tar.gz)."
  echo "The archive can be imported on another machine with import.sh."
  echo ""
  echo "Default output directory: current directory"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

COMPANY_NAME="$1"
OUTPUT_DIR="${2:-.}"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"
ROSTER_FILE="$COMPANY_DIR/org/roster.json"

if [[ ! -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' does not exist at $COMPANY_DIR"
  exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="${COMPANY_NAME}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_NAME"

echo "=== Exporting company '$COMPANY_NAME' ==="
echo ""

# Step 1: Generate session summaries for each agent
echo "Generating session summaries..."

python3 -c "
import json
import os
import glob
from datetime import datetime

company_dir = '$COMPANY_DIR'
roster_path = '$ROSTER_FILE'

if not os.path.isfile(roster_path):
    print('  No roster.json found, skipping summaries.')
    exit(0)

with open(roster_path) as f:
    roster = json.load(f)

# Load all channel messages
channel_messages = {}
channels_dir = os.path.join(company_dir, 'org', 'channels')
if os.path.isdir(channels_dir):
    for jsonl_file in glob.glob(os.path.join(channels_dir, '*.jsonl')):
        ch_name = os.path.basename(jsonl_file).replace('.jsonl', '')
        if ch_name.startswith('_archived_'):
            continue
        msgs = []
        with open(jsonl_file) as fh:
            for line in fh:
                line = line.strip()
                if line:
                    try:
                        msgs.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
        channel_messages[ch_name] = msgs

for agent in roster.get('agents', []):
    name = agent['name']
    display = agent.get('display_name', name)
    agent_dir = os.path.join(company_dir, 'agents', name)

    if not os.path.isdir(agent_dir):
        continue

    summary_path = os.path.join(agent_dir, 'memory', 'session-summary.md')
    os.makedirs(os.path.join(agent_dir, 'memory'), exist_ok=True)

    lines = []
    lines.append(f'# Session Summary — {display} ({name})')
    lines.append(f'')
    lines.append(f'**エクスポート日時**: {datetime.now().isoformat()}')
    lines.append(f'**ステータス**: {agent.get(\"status\", \"unknown\")}')
    lines.append(f'**ペルソナ**: {\", \".join(agent.get(\"personas\", []))}')
    lines.append(f'**スキル**: {\", \".join(agent.get(\"skills\", []))}')
    lines.append(f'**チャネル**: {\", \".join(agent.get(\"channels\", []))}')
    lines.append(f'**役割**: {agent.get(\"description\", \"\")}')
    lines.append(f'')

    # Existing memory files
    memory_dir = os.path.join(agent_dir, 'memory')
    if os.path.isdir(memory_dir):
        mem_files = [f for f in os.listdir(memory_dir)
                     if f.endswith('.md') and f not in ('session-summary.md', 'last_check.md')]
        if mem_files:
            lines.append('## 記憶ファイル')
            lines.append('')
            for mf in sorted(mem_files):
                mf_path = os.path.join(memory_dir, mf)
                try:
                    with open(mf_path) as fh:
                        content = fh.read().strip()
                    lines.append(f'### {mf}')
                    lines.append('')
                    lines.append(content)
                    lines.append('')
                except:
                    pass

    # Recent messages from/to this agent
    agent_msgs = []
    for ch_name, msgs in channel_messages.items():
        for m in msgs:
            if m.get('from') == name or name in m.get('mentions', []) or m.get('to') == name:
                agent_msgs.append(m)

    agent_msgs.sort(key=lambda m: m.get('ts', ''))
    recent = agent_msgs[-30:]  # last 30 messages

    if recent:
        lines.append('## 直近のチャネル活動（最新30件）')
        lines.append('')
        for m in recent:
            ts = m.get('ts', '?')[:19]
            fr = m.get('from', '?')
            ch = m.get('channel', '?')
            body = m.get('body', '')
            lines.append(f'- [{ts}] #{ch} **{fr}**: {body}')
        lines.append('')

    # Workspace files
    workspace = os.path.join(agent_dir, 'workspace')
    if os.path.isdir(workspace):
        ws_files = []
        for root, dirs, files in os.walk(workspace):
            for f in files:
                rel = os.path.relpath(os.path.join(root, f), workspace)
                ws_files.append(rel)
        if ws_files:
            lines.append('## ワークスペース内ファイル')
            lines.append('')
            for wf in sorted(ws_files):
                lines.append(f'- {wf}')
            lines.append('')

    with open(summary_path, 'w') as fh:
        fh.write('\n'.join(lines))
    print(f'  {name}: session-summary.md generated')
"

# Step 2: Generate manifest
echo "Generating manifest..."

python3 -c "
import json
import os
from datetime import datetime

company_dir = '$COMPANY_DIR'
company_name = '$COMPANY_NAME'
roster_path = '$ROSTER_FILE'
config_path = '$AGENTLATTICE_CONFIG'

manifest = {
    'company_name': company_name,
    'exported_at': datetime.now().isoformat(),
    'exported_from': os.uname().nodename,
    'agentlattice_version': '2.0',
}

# Agent info
if os.path.isfile(roster_path):
    with open(roster_path) as f:
        roster = json.load(f)
    manifest['agents'] = []
    for a in roster.get('agents', []):
        manifest['agents'].append({
            'name': a['name'],
            'display_name': a.get('display_name', ''),
            'status': a.get('status', 'unknown'),
            'personas': a.get('personas', []),
            'description': a.get('description', ''),
        })

# Channel info
channels_dir = os.path.join(company_dir, 'org', 'channels')
if os.path.isdir(channels_dir):
    manifest['channels'] = [
        f.replace('.jsonl', '')
        for f in sorted(os.listdir(channels_dir))
        if f.endswith('.jsonl') and not f.startswith('_archived_')
    ]

# Config snapshot (without machine-specific paths)
if os.path.isfile(config_path):
    with open(config_path) as f:
        cfg = json.load(f)
    manifest['config'] = {
        'default_loop_interval': cfg.get('default_loop_interval', '5m'),
        'default_channels': cfg.get('default_channels', ['general', 'management']),
        'max_panes_per_window': cfg.get('max_panes_per_window', 4),
        'dashboard_port': cfg.get('dashboard_port', 8390),
    }

manifest_path = os.path.join(company_dir, 'manifest.json')
with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)
print('  manifest.json generated')
"

# Step 3: Reset last_check.md for all agents (offsets are not portable)
echo "Resetting message offsets (will re-read on import)..."
find "$COMPANY_DIR/agents" -name "last_check.md" -exec rm -f {} \;

# Step 4: Create archive
echo "Creating archive..."
tar -czf "$ARCHIVE_PATH" -C "$AGENTLATTICE_HOME" "$COMPANY_NAME"

# Step 5: Clean up generated manifest (keep session summaries as they're useful)
rm -f "$COMPANY_DIR/manifest.json"

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)

echo ""
echo "=== Export complete ==="
echo "  Archive: $ARCHIVE_PATH"
echo "  Size: $ARCHIVE_SIZE"
echo ""
echo "To import on another machine:"
echo "  1. Install AgentLattice: git clone https://github.com/hiroshi75/agentlattice.git"
echo "  2. Run: bash <agentlattice-root>/scripts/import.sh $ARCHIVE_NAME"
