---
name: account-research
description: Research a company or person and get actionable sales intel. Works standalone with web search, supercharged when you connect enrichment tools or your CRM. Trigger with "research [company]", "look up [person]", "intel on [prospect]", "who is [name] at [company]", or "tell me about [company]".
---

# Account Research

Get a complete picture of any company or person before outreach. This skill always works with web search, and gets significantly better with enrichment and CRM data.

## How It Works

```
ALWAYS (works standalone via web search)
- Company overview: what they do, size, industry
- Recent news: funding, leadership changes, announcements
- Hiring signals: open roles, growth indicators
- Key people: leadership team from LinkedIn
- Product/service: what they sell, who they serve

SUPERCHARGED (when you connect your tools)
+ Enrichment: verified emails, phone, tech stack, org chart
+ CRM: prior relationship, past opportunities, contacts
```

## Getting Started

Just tell me who to research:
- "Research Stripe"
- "Look up the CTO at Notion"
- "Intel on acme.com"
- "Who is Sarah Chen at TechCorp?"
- "Tell me about [company] before my call"

## Output Format

### Quick Take
2-3 sentences: Who they are, why they might need you, best angle for outreach.

### Company Profile
Company name, website, industry, size, headquarters, founded, funding, revenue estimate.

#### What They Do
1-2 sentence description of their business, product, and customers.

#### Recent News
Headlines with dates and why they matter for outreach.

#### Hiring Signals
Open roles by department, notable roles, growth indicators.

### Key People
For each relevant contact: name, title, LinkedIn, background, tenure, talking points.

### Qualification Signals
- Positive signals with evidence
- Potential concerns to watch for
- Unknown gaps to ask about in discovery

### Recommended Approach
- Best entry point (person and why)
- Opening hook based on research
- Discovery questions about their situation, pain points, decision process

## Execution Flow

1. **Parse Request**: Identify company research, person + company, role-based search, or domain lookup
2. **Web Search**: Run searches for company info, news, funding, careers, people, product, customers
3. **Enrichment** (if connected): Firmographics, org chart, contact info, tech stack
4. **CRM Check** (if connected): Account history, contacts, opportunity history
5. **Synthesize**: Combine sources, prioritize accuracy, generate talking points and recommendations

## Research Variations

- **Company Research**: Business overview, news, hiring, leadership
- **Person Research**: Background, role, LinkedIn activity, talking points
- **Competitor Research**: Product comparison, positioning, win/loss patterns
- **Pre-Meeting Research**: Attendee backgrounds, recent news, relationship history

## Related Skills

- **call-prep** — Full meeting prep with this research plus context
- **draft-outreach** — Write personalized message based on research
