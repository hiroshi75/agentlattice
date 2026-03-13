---
name: daily-briefing
description: Get a prioritized action plan for your sales day. Works standalone or supercharged with calendar, CRM, email, and enrichment tools. Trigger with "morning briefing", "daily brief", "what's on my plate today", "prep my day", or "start my day".
---

# Daily Briefing

Get a prioritized action plan for your sales day. Combines pipeline data, meeting schedule, email priorities, and account intelligence into one scannable brief.

## How It Works

**Standalone Mode**: Share your meetings and priorities. The skill organizes them into a prioritized briefing.

**Supercharged Mode**: Connect calendar, CRM, email, and enrichment tools for automatic data pulling.

## Triggers

- "morning briefing" / "daily brief"
- "what's on my plate today?"
- "prep my day" / "start my day"

## Output Format

### Top Priority
The single most important action for today with context on why.

### Pipeline Snapshot
| Metric | Value |
|--------|-------|
| Open deals | [count] |
| Closing this week | [count + value] |
| Meetings today | [count] |
| Follow-ups due | [count] |

### Today's Meetings
For each meeting:
- Time, company, attendees
- Meeting type and stage
- Key context (last interaction, open items)
- One-line prep suggestion

### Pipeline Alerts
- Deals closing soon that need attention
- Stale deals (7+ days no activity)
- At-risk deals with warning signals
- Expansion opportunities

### Email Priorities
- Unread from key contacts / decision makers
- Replies waiting (sent but no response)
- Action items from recent threads

### Top 3 Actions
Ranked by urgency and impact:
1. [Most urgent action with context]
2. [Second priority]
3. [Third priority]

## Prioritization Logic

Priority ranking:
1. Deals closing today/tomorrow
2. High-value meetings requiring prep
3. Urgent emails from decision-makers
4. Deals closing this week
5. Stale opportunities needing follow-up
6. Routine follow-ups and admin

## Variants

- **Quick Brief**: "quick brief" or "tldr my day" — essential points only
- **End of Day Summary**: "end of day summary" — capture completed activities, plan tomorrow
