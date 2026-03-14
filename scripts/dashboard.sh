#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

usage() {
  echo "Usage: $0 <company-name> [port]"
  echo ""
  echo "Starts a simple dashboard server for the specified company."
  echo "Default port: 8390"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

COMPANY_NAME="$1"
PORT="${2:-8390}"
COMPANY_DIR="$AGENTLATTICE_HOME/$COMPANY_NAME"

if [[ ! -d "$COMPANY_DIR" ]]; then
  echo "Error: Company '$COMPANY_NAME' does not exist at $COMPANY_DIR"
  exit 1
fi

DASHBOARD_HTML="$AGENTLATTICE_ROOT/templates/dashboard/index.html"

if [[ ! -f "$DASHBOARD_HTML" ]]; then
  echo "Error: Dashboard HTML not found at $DASHBOARD_HTML"
  exit 1
fi

echo "Starting AgentLattice Dashboard for '$COMPANY_NAME'"
echo "  Company dir: $COMPANY_DIR"
echo "  URL: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop."

# Use Python's built-in HTTP server with a custom handler that:
# 1. Serves the dashboard HTML at /
# 2. Serves files from the company directory under /data/
python3 -c "
import http.server
import os
import json
import glob

COMPANY_DIR = '$COMPANY_DIR'
DASHBOARD_HTML = '$DASHBOARD_HTML'
PORT = $PORT

class DashboardHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress default logging

    def do_GET(self):
        if self.path == '/' or self.path == '/index.html':
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            with open(DASHBOARD_HTML, 'rb') as f:
                self.wfile.write(f.read())

        elif self.path == '/api/roster':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            roster_path = os.path.join(COMPANY_DIR, 'org', 'roster.json')
            if os.path.isfile(roster_path):
                with open(roster_path, 'r') as f:
                    self.wfile.write(f.read().encode())
            else:
                self.wfile.write(b'{\"agents\":[]}')

        elif self.path == '/api/channels':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            channels_dir = os.path.join(COMPANY_DIR, 'org', 'channels')
            result = {}
            if os.path.isdir(channels_dir):
                for f in sorted(glob.glob(os.path.join(channels_dir, '*.jsonl'))):
                    name = os.path.basename(f).replace('.jsonl', '')
                    if name.startswith('_archived_'):
                        continue
                    lines = []
                    with open(f, 'r') as fh:
                        for line in fh:
                            line = line.strip()
                            if line:
                                try:
                                    lines.append(json.loads(line))
                                except json.JSONDecodeError:
                                    pass
                    result[name] = {
                        'total_messages': len(lines),
                        'recent': lines[-20:] if lines else []
                    }
            self.wfile.write(json.dumps(result, ensure_ascii=False).encode())

        elif self.path == '/api/knowledge':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            knowledge_dir = os.path.join(COMPANY_DIR, 'org', 'knowledge')
            files = []
            if os.path.isdir(knowledge_dir):
                for f in sorted(glob.glob(os.path.join(knowledge_dir, '*.md'))):
                    name = os.path.basename(f)
                    stat = os.stat(f)
                    files.append({
                        'name': name,
                        'size': stat.st_size,
                        'modified': stat.st_mtime
                    })
            self.wfile.write(json.dumps(files, ensure_ascii=False).encode())

        elif self.path == '/api/dashboard':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            dashboard_path = os.path.join(COMPANY_DIR, 'org', 'dashboard.md')
            if os.path.isfile(dashboard_path):
                with open(dashboard_path, 'r') as f:
                    self.wfile.write(f.read().encode())
            else:
                self.wfile.write('# Dashboard\n\nNo dashboard.md found. An agent with the dashboard skill will generate it.'.encode())

        else:
            self.send_response(404)
            self.end_headers()

server = http.server.HTTPServer(('0.0.0.0', PORT), DashboardHandler)
print(f'Dashboard server running on http://localhost:{PORT}')
server.serve_forever()
"
