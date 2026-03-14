# AgentLattice Persona Templates

Curated persona definitions sourced from [agency-agents](https://github.com/msitarzewski/agency-agents).
These templates are used when hiring agents — multiple personas can be blended together.

## Engineering (6 personas)

| File | Name | Description |
|------|------|-------------|
| `frontend-developer.md` | Frontend Developer | Expert in modern web technologies, responsive design, accessibility, and performance optimization |
| `backend-architect.md` | Backend Architect | Senior architect specializing in scalable system design, database architecture, APIs, and cloud infrastructure |
| `ai-engineer.md` | AI Engineer | AI/ML engineer focused on model development, deployment, and integration into production systems |
| `code-reviewer.md` | Code Reviewer | Constructive code reviewer focused on correctness, security, maintainability, and performance |
| `devops-automator.md` | DevOps Automator | Infrastructure automation specialist for CI/CD pipelines, IaC, and cloud operations |
| `technical-writer.md` | Technical Writer | Documentation specialist for developer docs, API references, READMEs, and tutorials |

## Marketing (5 personas)

| File | Name | Description |
|------|------|-------------|
| `growth-hacker.md` | Growth Hacker | Growth strategist for rapid user acquisition through data-driven experimentation and viral loops |
| `seo-specialist.md` | SEO Specialist | Search optimization strategist for technical SEO, content optimization, and organic growth |
| `content-creator.md` | Content Creator | Multi-platform content strategist for editorial calendars, brand storytelling, and audience engagement |
| `reddit-community-builder.md` | Reddit Community Builder | Reddit marketing specialist focused on authentic community engagement and value-driven content |
| `social-media-strategist.md` | Social Media Strategist | Cross-platform social strategist for LinkedIn, Twitter, campaigns, and thought leadership |

## Product (3 personas)

| File | Name | Description |
|------|------|-------------|
| `sprint-prioritizer.md` | Sprint Prioritizer | Product manager for agile sprint planning, feature prioritization with RICE/MoSCoW/Kano frameworks |
| `trend-researcher.md` | Trend Researcher | Market intelligence analyst for emerging trends, competitive analysis, and opportunity assessment |
| `feedback-synthesizer.md` | Feedback Synthesizer | User feedback analyst who transforms qualitative feedback into quantitative priorities and recommendations |

## QA (1 persona)

| File | Name | Description |
|------|------|-------------|
| `beta-tester.md` | Beta Tester | Quality-focused tester evaluating products from general, technical, and accessibility perspectives |

## Design (2 personas)

| File | Name | Description |
|------|------|-------------|
| `ui-designer.md` | UI Designer | Visual design systems specialist for component libraries, pixel-perfect interfaces, and accessibility |
| `ux-architect.md` | UX Architect | Technical architecture and UX foundation specialist providing CSS systems and implementation guidance |

## Specialized (4 personas)

| File | Name | Description |
|------|------|-------------|
| `agents-orchestrator.md` | Agents Orchestrator | Autonomous pipeline manager that coordinates specialist agents through dev-QA quality loops |
| `developer-advocate.md` | Developer Advocate | Developer relations engineer for community building, DX optimization, and technical content creation |
| `mcp-builder.md` | MCP Builder | Model Context Protocol server developer for building AI agent tools and integrations |
| `build-bot.md` | Build Bot | CI/CD monitoring agent that watches build status, detects failures, and auto-fixes common issues |

---

## Usage

When hiring an agent, reference personas by their kebab-case filename (without `.md`):

```json
{
  "name": "alice",
  "personas": ["growth-hacker", "seo-specialist"],
  "description": "Marketing generalist with SEO and growth expertise"
}
```

Multiple personas can be blended. The management console will merge Identity, Core Mission, Critical Rules, Workflow, and Communication Style sections from each selected persona into a unified agent CLAUDE.md.

## Source

All personas are adapted from [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) (MIT License).
Each file includes a `source` field in its frontmatter linking to the original.
