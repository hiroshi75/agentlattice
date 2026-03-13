#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name> <create|list> [channel-name]"
  echo ""
  echo "Channel operations for a company."
  echo ""
  echo "Commands:"
  echo "  create <channel-name>   Create a new channel (.jsonl file)"
  echo "  list                    List all channels with message counts"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

COMPANY_NAME="$1"
COMMAND="$2"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"
CHANNELS_DIR="$COMPANY_DIR/org/channels"

# Validate company exists
if [[ ! -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' does not exist at $COMPANY_DIR"
  exit 1
fi

# Validate channels directory exists
if [[ ! -d "$CHANNELS_DIR" ]]; then
  echo "Error: Channels directory not found at $CHANNELS_DIR"
  exit 1
fi

case "$COMMAND" in
  create)
    if [[ $# -lt 3 ]]; then
      echo "Error: Channel name required."
      echo "Usage: $0 <company-name> create <channel-name>"
      exit 1
    fi
    CHANNEL_NAME="$3"
    CHANNEL_FILE="$CHANNELS_DIR/$CHANNEL_NAME.jsonl"

    if [[ -f "$CHANNEL_FILE" ]]; then
      echo "Error: Channel '$CHANNEL_NAME' already exists at $CHANNEL_FILE"
      exit 1
    fi

    touch "$CHANNEL_FILE"
    echo "Channel '$CHANNEL_NAME' created successfully at $CHANNEL_FILE"
    ;;

  list)
    echo "Channels in company '$COMPANY_NAME':"
    echo ""
    printf "%-25s %-10s\n" "CHANNEL" "MESSAGES"
    printf "%-25s %-10s\n" "-------" "--------"

    for channel_file in "$CHANNELS_DIR"/*.jsonl; do
      if [[ ! -f "$channel_file" ]]; then
        echo "  (no channels found)"
        break
      fi
      channel_name="$(basename "$channel_file" .jsonl)"
      line_count=$(wc -l < "$channel_file" | tr -d ' ')
      printf "%-25s %-10s\n" "$channel_name" "$line_count"
    done
    ;;

  *)
    echo "Error: Unknown command '$COMMAND'"
    echo ""
    usage
    ;;
esac
