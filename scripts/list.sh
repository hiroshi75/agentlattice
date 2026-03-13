#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 [company-name]"
  echo ""
  echo "Lists agents for a company, or lists all companies if no company is specified."
  exit 1
}

# If -h or --help, show usage
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

list_companies() {
  local companies_dir="$AGENTLATTICE_HOME"
  if [[ ! -d "$companies_dir" ]]; then
    echo "No companies directory found."
    exit 0
  fi

  local companies=()
  for dir in "$companies_dir"/*/; do
    [[ -d "$dir" ]] && companies+=("$(basename "$dir")")
  done

  if [[ ${#companies[@]} -eq 0 ]]; then
    echo "No companies found."
    exit 0
  fi

  printf "%-25s %-10s\n" "COMPANY" "AGENTS"
  printf "%-25s %-10s\n" "-------" "------"
  for company in "${companies[@]}"; do
    local roster="$companies_dir/$company/org/roster.json"
    local count=0
    if [[ -f "$roster" ]]; then
      count=$(python3 -c "
import json
with open('$roster') as f:
    print(len(json.load(f)['agents']))
" 2>/dev/null || echo "0")
    fi
    printf "%-25s %-10s\n" "$company" "$count"
  done
}

list_agents() {
  local company_name="$1"
  local company_dir="$AGENTLATTICE_HOME/$company_name"
  local roster_file="$company_dir/org/roster.json"

  if [[ ! -d "$company_dir" ]]; then
    echo "Error: Company '$company_name' does not exist."
    exit 1
  fi

  if [[ ! -f "$roster_file" ]]; then
    echo "Error: Roster file not found at $roster_file"
    exit 1
  fi

  python3 -c "
import json

with open('$roster_file') as f:
    roster = json.load(f)

agents = roster.get('agents', [])
if not agents:
    print('No agents in company \"$company_name\".')
else:
    print(f'Agents in company \"$company_name\" ({len(agents)} total):')
    print()
    header = f'{\"NAME\":<15} {\"STATUS\":<12} {\"PERSONAS\":<35} {\"DESCRIPTION\"}'
    print(header)
    print(f'{\"----\":<15} {\"------\":<12} {\"--------\":<35} {\"-----------\"}')
    for a in agents:
        name = a.get('name', '?')
        status = a.get('status', '?')
        personas = ', '.join(a.get('personas', []))
        desc = a.get('description', '')
        # Truncate long fields
        if len(personas) > 33:
            personas = personas[:30] + '...'
        if len(desc) > 50:
            desc = desc[:47] + '...'
        print(f'{name:<15} {status:<12} {personas:<35} {desc}')
"
}

if [[ $# -eq 0 ]]; then
  list_companies
else
  list_agents "$1"
fi
