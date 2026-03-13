#!/usr/bin/env bash
# Common functions for AgentLattice scripts

AGENTLATTICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTLATTICE_HOME="${AGENTLATTICE_HOME:-$HOME/.agentlattice}"
AGENTLATTICE_CONFIG="$AGENTLATTICE_HOME/config.json"

# Read a value from config.json, with fallback
# Usage: config_get <key> <default>
config_get() {
  local key="$1"
  local default="${2:-}"
  if [[ -f "$AGENTLATTICE_CONFIG" ]]; then
    local value
    value=$(python3 -c "
import json, sys
with open('$AGENTLATTICE_CONFIG') as f:
    cfg = json.load(f)
print(cfg.get('$key', ''))" 2>/dev/null)
    if [[ -n "$value" ]]; then
      echo "$value"
      return
    fi
  fi
  echo "$default"
}

# Override AGENTLATTICE_ROOT from config if set
_config_root=$(config_get "agentlattice_root" "")
if [[ -n "$_config_root" ]]; then
  AGENTLATTICE_ROOT="$_config_root"
fi

# Ensure ~/.agentlattice/ exists and has config.json
ensure_home() {
  if [[ ! -d "$AGENTLATTICE_HOME" ]]; then
    mkdir -p "$AGENTLATTICE_HOME"
    echo "Created $AGENTLATTICE_HOME"
  fi
  if [[ ! -f "$AGENTLATTICE_CONFIG" ]]; then
    cat > "$AGENTLATTICE_CONFIG" <<EOF
{
  "agentlattice_root": "$AGENTLATTICE_ROOT",
  "default_loop_interval": "5m",
  "default_channels": ["general"],
  "user_name": "$(whoami)"
}
EOF
    echo "Created config at $AGENTLATTICE_CONFIG"
  fi
}
