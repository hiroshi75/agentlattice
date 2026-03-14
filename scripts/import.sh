#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"
ensure_home

usage() {
  echo "Usage: $0 <archive-path>"
  echo ""
  echo "Imports a company from an archive created by export.sh."
  echo "Extracts to ~/.agentlattice/ and prepares for startup."
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

ARCHIVE_PATH="$1"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "Error: Archive not found at $ARCHIVE_PATH"
  exit 1
fi

# Detect company name from archive
COMPANY_NAME=$(tar -tzf "$ARCHIVE_PATH" | head -1 | cut -d'/' -f1)

if [[ -z "$COMPANY_NAME" ]]; then
  echo "Error: Could not detect company name from archive"
  exit 1
fi

COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"

echo "=== Importing company '$COMPANY_NAME' ==="
echo ""

# Check if company already exists
if [[ -d "$COMPANY_DIR" ]]; then
  echo "Warning: Company '$COMPANY_NAME' already exists at $COMPANY_DIR"
  echo "Import will overwrite existing files."
  echo ""
  read -p "Continue? [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Import cancelled."
    exit 0
  fi
fi

# Extract archive
echo "Extracting archive..."
tar -xzf "$ARCHIVE_PATH" -C "$AGENTLATTICE_HOME"
echo "  Extracted to $COMPANY_DIR"

# Read and display manifest
MANIFEST="$COMPANY_DIR/manifest.json"
if [[ -f "$MANIFEST" ]]; then
  echo ""
  echo "=== Manifest ==="
  python3 -c "
import json
with open('$MANIFEST') as f:
    m = json.load(f)
print(f\"  Company: {m['company_name']}\")
print(f\"  Exported: {m['exported_at']}\")
print(f\"  From: {m.get('exported_from', 'unknown')}\")
agents = m.get('agents', [])
print(f\"  Agents: {len(agents)}\")
for a in agents:
    status = a.get('status', '?')
    print(f\"    - {a.get('display_name', a['name'])} ({a['name']}): {status}\")
channels = m.get('channels', [])
print(f\"  Channels: {', '.join(channels)}\")

# Apply portable config values to local config
config = m.get('config', {})
if config:
    import os
    config_path = '$AGENTLATTICE_CONFIG'
    if os.path.isfile(config_path):
        with open(config_path) as f:
            local_cfg = json.load(f)
        for key in ('default_loop_interval', 'max_panes_per_window', 'dashboard_port'):
            if key in config:
                local_cfg[key] = config[key]
        with open(config_path, 'w') as f:
            json.dump(local_cfg, f, indent=2, ensure_ascii=False)
        print(f'')
        print(f'  Config merged (loop_interval, max_panes, dashboard_port)')
"
  # Clean up manifest after display
  rm -f "$MANIFEST"
fi

# Verify CLAUDE.md exists
if [[ ! -f "$COMPANY_DIR/CLAUDE.md" ]]; then
  echo ""
  echo "Warning: No CLAUDE.md found. You may need to regenerate it."
fi

echo ""
echo "=== Import complete ==="
echo ""
echo "Next steps:"
echo "  1. Start a tmux session:  tmux new -s agentlattice"
echo "  2. Launch all agents:     bash $AGENTLATTICE_ROOT/scripts/start.sh $COMPANY_NAME"
echo "  Or manage manually:       cd $COMPANY_DIR && claude"
echo ""
echo "Note: Claude Code sessions are not portable across machines."
echo "Each agent has a session-summary.md in memory/ with context from the previous environment."
echo "Agents will read these summaries on startup to restore context."
