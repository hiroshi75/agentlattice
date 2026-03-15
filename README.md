# AgentLattice

A multi-agent system built entirely on [Claude Code](https://docs.anthropic.com/en/docs/claude-code)'s native features. Each agent runs as an independent Claude Code instance in a tmux pane, communicating through Slack-style JSONL channels.

No custom framework. No orchestration layer. Just Claude Code, Markdown, and shell scripts.

## How It Works

```
You (natural language) → Management Console (Claude Code)
                              ↓ hire / command / suspend
                    ┌─────────┼─────────┐
                    │         │         │
                  Agent A   Agent B   Agent C
                  (tmux)    (tmux)    (tmux)
                    │         │         │
                    └────── JSONL ──────┘
                         channels
```

- **Agents = Claude Code instances**, each with their own `CLAUDE.md` (persona) and `.claude/skills/` (capabilities)
- **Communication** via JSONL files in shared `org/channels/` — Slack-style with `@mentions`, DMs, and threaded replies (`reply_to`)
- **Autonomous operation** using Claude Code's `/loop` — agents poll for messages, triage, and execute tasks
- **Personas** from [agency-agents](https://github.com/msitarzewski/agency-agents) — blendable, with built-in autonomy rules
- **Skills** from [knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) (30+ skill definitions)
- **Multi-company** support — run multiple independent teams under `~/.agentlattice/`
- **Team presets** — pre-configured team compositions (startup, dev-team, content-team)
- **Web dashboard** — real-time browser UI with 10-second auto-refresh

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [tmux](https://github.com/tmux/tmux)
- Python 3 (for helper scripts)
- [qmd](https://github.com/tobi/qmd) (optional, for Markdown search)

### 1. Clone and initialize

```bash
git clone https://github.com/hiroshi75/agentlattice.git
cd agentlattice
claude  # starts the root management console
```

### 2. Create a company

In the management console, just say:

> "Create a new company called my-startup for building AI developer tools"

This runs `scripts/init.sh`, generates the company directory at `~/.agentlattice/my-startup/`, and creates the company's `CLAUDE.md` with `general` and `management` channels.

### 3. Manage the company

```bash
cd ~/.agentlattice/my-startup
claude  # starts the company management console
```

### 4. Hire agents

In the company console:

> "Hire a marketing lead named alice-marketing with the growth-hacker and seo-specialist personas"

Or use a team preset:

> "startup プリセットでチームを構成して"

The console will:
1. Blend the selected personas into a unified `CLAUDE.md`
2. Copy selected skills to `.claude/skills/`
3. Update `org/roster.json`
4. Open a new tmux pane with Claude Code (tiled layout, auto-overflow to new window)
5. Auto-start `/loop` for autonomous operation

### 5. Watch them work

Agents autonomously:
- Check channels for messages addressed to them (offset-based, efficient)
- Triage and respond to requests
- Execute tasks and save deliverables
- Generate ideas proactively each cycle
- Report progress back to channels
- Share knowledge in `org/knowledge/`

### 6. Monitor via dashboard

```bash
bash scripts/dashboard.sh my-startup
# → http://localhost:8390
```

Opens a dark-themed web UI showing agent roster, channel activity, shared knowledge, and dashboard reports — auto-refreshing every 10 seconds.

## Architecture

### Directory Structure

```
# System code (git-managed)
agentlattice/
├── CLAUDE.md                    # Root management console
├── SPEC.md                      # Full specification
├── templates/
│   ├── personas/                # 21 agent personas
│   ├── skills/                  # 30+ skills
│   ├── team-presets/            # Pre-configured team compositions
│   ├── dashboard/               # Dashboard HTML + assets
│   ├── company-claude-md.md     # Company console template
│   └── agent-claude-md.md       # Agent CLAUDE.md template
└── scripts/
    ├── init.sh                  # Initialize a new company
    ├── hire.sh                  # Launch agent in tmux (tiled layout)
    ├── fire.sh                  # Suspend an agent
    ├── start.sh                 # Start all active agents
    ├── stop.sh                  # Stop all agents (preserve status)
    ├── export.sh                # Export company to portable archive
    ├── import.sh                # Import company from archive
    ├── list.sh                  # List companies/agents
    ├── status.sh                # Agent activity metrics
    ├── dashboard.sh             # Web dashboard server
    └── channel.sh               # Channel operations

# Runtime data (outside git)
~/.agentlattice/
├── config.json                  # Global settings
└── <company>/
    ├── CLAUDE.md                # Company management console
    ├── org/
    │   ├── channels/*.jsonl     # Communication channels
    │   ├── knowledge/           # Shared knowledge (Markdown)
    │   ├── tasks/               # Task backlog
    │   ├── dashboard.md         # Dashboard report (auto-generated)
    │   └── roster.json          # Agent registry
    └── agents/<name>/
        ├── CLAUDE.md            # Blended persona
        ├── .claude/skills/      # Assigned skills
        ├── workspace/           # Deliverables
        └── memory/              # Agent-specific memory
```

### Channel Communication

Agents communicate by appending JSON lines to shared `.jsonl` files — with support for threads via `reply_to`:

```json
{"id":"msg_20260313_143022_001","ts":"2026-03-13T14:30:22Z","from":"alice-marketing","channel":"general","to":null,"mentions":["bob-engineering"],"type":"message","reply_to":null,"body":"@bob-engineering Competitor analysis is ready. See knowledge/competitor-analysis.md"}
```

Special channels:
- `general` — team-wide communication
- `management` — priority channel for management directives (agents check first)
- `dm_<name1>_<name2>` — direct messages between two agents

### Agent Loop Cycle

Each `/loop` iteration:

1. **Check messages** — read JSONL channels from last offset (line-number based, no timestamp parsing overhead)
2. **Triage** — classify as immediate response, task, info, or redirect
3. **Execute** — work on highest-priority tasks
4. **Report** — post results back to channels
5. **Ideate** — propose at least one improvement per cycle

### Agent Behavior Principles

All personas include built-in autonomy rules:

- **Act autonomously** — find next tasks without waiting for instructions
- **One idea per cycle** — proactively suggest improvements each loop
- **No idle time** — if tasks are done, find new ones; report after, not before
- **Execute immediately** — skip effort estimation, ship small and iterate
- **Output-driven** — attach prototypes and artifacts alongside proposals

### Self-Hiring

Agents with the `hire-agent` skill can recruit new team members autonomously — reading persona/skill templates, generating CLAUDE.md, and launching new agents via tmux.

### tmux Layout

Agents are arranged in tiled layout. When a window reaches `max_panes_per_window` (default: 4), new agents open in a new tmux window automatically.

### Portability (Export / Import)

Companies can be exported to a portable archive and imported on another machine:

```bash
# Export
bash scripts/export.sh my-startup ~/Desktop
# → my-startup_20260314_120000.tar.gz

# Import (on another machine)
bash scripts/import.sh my-startup_20260314_120000.tar.gz
bash scripts/start.sh my-startup
```

Claude Code sessions are path-dependent and cannot be transferred. Instead, `export.sh` generates a `session-summary.md` for each agent containing their memory files, recent channel activity, and workspace file list. Agents read these summaries on startup to restore context.

## Included Templates

### Personas (21)

| Division | Personas |
|---|---|
| Engineering | Frontend Developer, Backend Architect, AI Engineer, Code Reviewer, DevOps Automator, Technical Writer |
| Marketing | Growth Hacker, SEO Specialist, Content Creator, Reddit Community Builder, Social Media Strategist |
| Product | Sprint Prioritizer, Trend Researcher, Feedback Synthesizer |
| QA | Beta Tester |
| Design | UI Designer, UX Architect |
| Specialized | Agents Orchestrator, Developer Advocate, MCP Builder, Build Bot |

### Skills (33)

| Category | Skills |
|---|---|
| Engineering | code-review, documentation, incident-response, system-design, tech-debt, testing-strategy |
| Marketing | brand-voice, campaign-planning, competitive-analysis, content-creation, performance-analytics |
| Product Mgmt | competitive-analysis, feature-spec, metrics-tracking, roadmap-management, stakeholder-comms, user-research-synthesis |
| Sales | account-research, call-prep, competitive-intelligence, create-an-asset, daily-briefing, draft-outreach |
| Data | data-context-extractor, data-exploration, data-validation, data-visualization, interactive-dashboard-builder, sql-queries, statistical-analysis |
| AgentLattice | hire-agent, dashboard, daily-report |

### Team Presets

| Preset | Agents | Use Case |
|---|---|---|
| `startup` | CEO, Dev, Marketer, Tester | MVP development and market validation |
| `dev-team` | PM, Frontend, Backend, DevOps, QA | Full software development lifecycle |
| `content-team` | Strategist, Writer, SEO, Social | Content marketing and distribution |

## Configuration

`~/.agentlattice/config.json` (auto-generated on first `init.sh`):

```json
{
  "agentlattice_root": "/path/to/agentlattice",
  "default_loop_interval": "5m",
  "default_channels": ["general", "management"],
  "max_panes_per_window": 4,
  "user_name": "your-username"
}
```

| Field | Description |
|---|---|
| `agentlattice_root` | Path to the system code (templates, scripts) |
| `default_loop_interval` | Default `/loop` interval for agents |
| `default_channels` | Channels auto-created for new companies |
| `max_panes_per_window` | Max tmux panes per window before overflow to new window |
| `user_name` | Your name as shown in channel messages |

## Credits

- Agent personas adapted from [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents)
- Skills adapted from [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)

## License

MIT

## Attribution

This project incorporates source code from the following repositories:

- [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — Agent persona definitions (`templates/personas/`)
- [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) — Skill definitions (`templates/skills/`)
