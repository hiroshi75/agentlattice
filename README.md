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
- **Communication** via JSONL files in shared `org/channels/` — like Slack, with `@mentions` and multiple channels
- **Autonomous operation** using Claude Code's `/loop` — agents poll for messages, triage, and execute tasks
- **Personas** from [agency-agents](https://github.com/msitarzewski/agency-agents) (144+ agent definitions) — blendable
- **Skills** from [knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) (30+ skill definitions)
- **Multi-company** support — run multiple independent teams under `~/.agentlattice/`

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

This runs `scripts/init.sh`, generates the company directory at `~/.agentlattice/my-startup/`, and creates the company's `CLAUDE.md`.

### 3. Manage the company

```bash
cd ~/.agentlattice/my-startup
claude  # starts the company management console
```

### 4. Hire agents

In the company console:

> "Hire a marketing lead named alice with the growth-hacker and seo-specialist personas"

The console will:
1. Blend the selected personas into a unified `CLAUDE.md`
2. Copy selected skills to `.claude/skills/`
3. Update `org/roster.json`
4. Open a new tmux pane with Claude Code
5. Auto-start `/loop` for autonomous operation

### 5. Watch them work

Agents autonomously:
- Check channels for messages addressed to them
- Triage and respond to requests
- Execute tasks and save deliverables
- Report progress back to channels
- Share knowledge in `org/knowledge/`

## Architecture

### Directory Structure

```
# System code (git-managed)
agentlattice/
├── CLAUDE.md                    # Root management console
├── SPEC.md                      # Full specification
├── templates/
│   ├── personas/                # 19 agent personas (engineering, marketing, etc.)
│   ├── skills/                  # 30+ skills (code-review, campaign-planning, etc.)
│   ├── company-claude-md.md     # Company console template
│   └── agent-claude-md.md       # Agent CLAUDE.md template
└── scripts/
    ├── init.sh                  # Initialize a new company
    ├── hire.sh                  # Launch agent in tmux + auto /loop
    ├── fire.sh                  # Suspend an agent
    ├── list.sh                  # List companies/agents
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
    │   └── roster.json          # Agent registry
    └── agents/<name>/
        ├── CLAUDE.md            # Blended persona
        ├── .claude/skills/      # Assigned skills
        ├── workspace/           # Deliverables
        └── memory/              # Agent-specific memory
```

### Channel Communication

Agents communicate by appending JSON lines to shared `.jsonl` files:

```json
{"id":"msg_20260313_143022_001","ts":"2026-03-13T14:30:22Z","from":"alice","channel":"general","to":null,"mentions":["bob"],"type":"message","body":"@bob Competitor analysis is ready. See knowledge/competitor-analysis.md"}
```

### Agent Loop Cycle

Each `/loop` iteration:

1. **Check messages** — read JSONL channels for mentions and new messages
2. **Triage** — classify as immediate response, task, info, or redirect
3. **Execute** — work on highest-priority tasks
4. **Report** — post results back to channels

### Self-Hiring

Agents with the `hire-agent` skill can recruit new team members autonomously — reading persona/skill templates, generating CLAUDE.md, and launching new agents via tmux.

## Included Templates

### Personas (19)

| Division | Personas |
|---|---|
| Engineering | Frontend Developer, Backend Architect, AI Engineer, Code Reviewer, DevOps Automator, Technical Writer |
| Marketing | Growth Hacker, SEO Specialist, Content Creator, Reddit Community Builder, Social Media Strategist |
| Product | Sprint Prioritizer, Trend Researcher, Feedback Synthesizer |
| Design | UI Designer, UX Architect |
| Specialized | Agents Orchestrator, Developer Advocate, MCP Builder |

### Skills (31)

| Category | Skills |
|---|---|
| Engineering | code-review, documentation, incident-response, system-design, tech-debt, testing-strategy |
| Marketing | brand-voice, campaign-planning, competitive-analysis, content-creation, performance-analytics |
| Product Mgmt | competitive-analysis, feature-spec, metrics-tracking, roadmap-management, stakeholder-comms, user-research-synthesis |
| Sales | account-research, call-prep, competitive-intelligence, create-an-asset, daily-briefing, draft-outreach |
| Data | data-context-extractor, data-exploration, data-validation, data-visualization, interactive-dashboard-builder, sql-queries, statistical-analysis |
| AgentLattice | hire-agent |

## Configuration

`~/.agentlattice/config.json` (auto-generated on first `init.sh`):

```json
{
  "agentlattice_root": "/path/to/agentlattice",
  "default_loop_interval": "5m",
  "default_channels": ["general"],
  "user_name": "your-username"
}
```

## Credits

- Agent personas adapted from [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents)
- Skills adapted from [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)

## License

MIT
