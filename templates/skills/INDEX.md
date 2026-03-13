# AgentLattice Skill Templates

Skills sourced from [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins). Each skill is a Claude Code compatible `SKILL.md` file with YAML frontmatter and can be directly copied to an agent's `.claude/skills/` directory.

## Engineering (6 skills)

| Skill | Description |
|-------|-------------|
| `engineering/code-review` | Review code for bugs, security vulnerabilities, performance issues, and maintainability |
| `engineering/documentation` | Write and maintain technical documentation — READMEs, API docs, runbooks, architecture docs |
| `engineering/incident-response` | Triage and manage production incidents from detection through postmortem |
| `engineering/system-design` | Design systems, services, and architectures with trade-off analysis |
| `engineering/tech-debt` | Identify, categorize, and prioritize technical debt with remediation plans |
| `engineering/testing-strategy` | Design test strategies and test plans balancing coverage, speed, and maintenance |

## Marketing (5 skills)

| Skill | Description |
|-------|-------------|
| `marketing/brand-voice` | Apply and enforce brand voice, style guide, and messaging pillars across content |
| `marketing/campaign-planning` | Plan campaigns with objectives, audience segmentation, channel strategy, and KPIs |
| `marketing/competitive-analysis` | Research competitors — positioning, messaging, content strategy, battlecards |
| `marketing/content-creation` | Draft content across channels — blog, social, email, landing pages, press releases |
| `marketing/performance-analytics` | Analyze marketing performance with metrics, trend analysis, and optimization recs |

## Product Management (6 skills)

| Skill | Description |
|-------|-------------|
| `product-management/competitive-analysis` | Feature comparison matrices, positioning analysis, win/loss analysis, market trends |
| `product-management/feature-spec` | Write PRDs with problem statements, user stories, requirements, and success metrics |
| `product-management/metrics-tracking` | Define, track, and analyze product metrics — OKRs, dashboards, metric reviews |
| `product-management/roadmap-management` | Plan and prioritize roadmaps using RICE, MoSCoW, ICE, Now/Next/Later |
| `product-management/stakeholder-comms` | Draft stakeholder updates — exec reports, engineering updates, risk comms, ADRs |
| `product-management/user-research-synthesis` | Synthesize qualitative and quantitative research into insights and personas |

## Sales (6 skills)

| Skill | Description |
|-------|-------------|
| `sales/account-research` | Research companies and people for actionable sales intel |
| `sales/call-prep` | Prepare for sales meetings with research, context, and talking points |
| `sales/competitive-intelligence` | Generate interactive battlecards for sales conversations |
| `sales/create-an-asset` | Generate tailored sales assets — landing pages, decks, one-pagers, workflow demos |
| `sales/daily-briefing` | Get a prioritized daily action plan combining pipeline, meetings, and email |
| `sales/draft-outreach` | Draft personalized outreach messages using research-first methodology |

## Data (7 skills)

| Skill | Description |
|-------|-------------|
| `data/data-context-extractor` | Capture and codify company-specific data knowledge and tribal knowledge |
| `data/data-exploration` | Profile and explore datasets — shape, quality, patterns, schema documentation |
| `data/data-validation` | QA analysis before sharing — methodology checks, accuracy verification, bias detection |
| `data/data-visualization` | Create effective visualizations with Python (matplotlib, seaborn, plotly) |
| `data/interactive-dashboard-builder` | Build self-contained HTML/JS dashboards with Chart.js and interactive filtering |
| `data/sql-queries` | Write correct, performant SQL across Snowflake, BigQuery, Databricks, PostgreSQL |
| `data/statistical-analysis` | Descriptive stats, trend analysis, outlier detection, hypothesis testing |

---

## Usage

To assign a skill to an agent, copy its directory to the agent's skill path:

```bash
cp -r templates/skills/marketing/content-creation agents/<name>/.claude/skills/content-creation
```

Skills can be combined freely. For example, a marketing agent might get:
- `marketing/content-creation`
- `marketing/campaign-planning`
- `marketing/performance-analytics`

## Total: 30 skills across 5 plugins
