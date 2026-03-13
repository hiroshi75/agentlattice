---
name: interactive-dashboard-builder
description: Build self-contained HTML/JavaScript dashboards with Chart.js, featuring interactive filtering and professional styling. Use when creating data dashboards, building interactive reports, or presenting analytical results in a shareable format.
---

# Interactive Dashboard Builder

Create self-contained HTML/JavaScript dashboards using Chart.js with interactive filtering and professional styling. No server dependencies required.

## Architecture

Dashboards follow a class-based pattern with embedded data and real-time filtering:
- Header with filters
- KPI cards
- Chart containers
- Data tables
- Footer with metadata

## Components

### KPI Cards
Display key metrics with formatting (currency, percentage, number) and comparison indicators.

### Charts (Chart.js 4.5.1)
- **Line charts**: Time series and trends
- **Bar charts**: Comparisons and rankings
- **Doughnut charts**: Composition and proportions

All charts support custom formatting, responsive sizing, and coordinated filtering.

### Interactive Filters
- Dropdown selectors for dimensions
- Date range pickers
- All filters update KPIs, charts, and tables simultaneously

### Data Tables
- Sortable columns
- Formatted values
- Pagination for large datasets

## Styling System

CSS variables establish:
- Color palette (primary, secondary, accent, status colors)
- Spacing scale
- Typography (Inter font family)
- Responsive breakpoints

Semantic HTML with grid-based card layouts that adapt to mobile viewports.

## Data Size Guidelines

| Data Size | Recommendation |
|-----------|---------------|
| <1,000 rows | Embed directly; full interactivity |
| 1,000-10,000 rows | Embed with pre-aggregation for charts |
| 10,000+ rows | Pre-aggregate server-side only |

### Performance Tips
- Keep under 500 data points per line series
- Cap bar charts at 50 categories
- Use pre-aggregation rather than raw data
- Implement pagination for tables beyond 100-200 rows
- Disable animations in multi-chart dashboards

## Output

Self-contained HTML file with all CSS and JavaScript inline. No external dependencies except Google Fonts. Shareable as a single file via email, static hosting, or embedded in other pages.

## Dashboard Design Principles

1. Lead with metrics that map to business questions
2. Show trends, not just snapshots
3. Include comparison context (prior period, target)
4. Use consistent color coding for status
5. Group by business question or funnel stage
6. Keep to one screen — detail in expandable sections
