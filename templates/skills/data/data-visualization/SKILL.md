---
name: data-visualization
description: Create effective data visualizations with Python (matplotlib, seaborn, plotly). Use when building charts, choosing the right chart type for a dataset, creating publication-quality figures, or applying design principles like accessibility and color theory.
---

# Data Visualization Skill

Chart selection guidance, Python visualization code patterns, design principles, and accessibility considerations.

## Chart Selection Guide

| What You're Showing | Best Chart | Alternatives |
|---|---|---|
| Trend over time | Line chart | Area chart |
| Comparison across categories | Vertical bar chart | Horizontal bar, lollipop |
| Ranking | Horizontal bar chart | Dot plot, slope chart |
| Part-to-whole composition | Stacked bar chart | Treemap, waffle chart |
| Composition over time | Stacked area chart | 100% stacked bar |
| Distribution | Histogram | Box plot, violin plot |
| Correlation (2 variables) | Scatter plot | Bubble chart |
| Correlation (many variables) | Heatmap | Pair plot |
| Geographic patterns | Choropleth map | Bubble map |
| Flow / process | Sankey diagram | Funnel chart |
| Multiple KPIs at once | Small multiples | Dashboard |

### When NOT to Use
- **Pie charts**: Avoid unless <6 categories. Use bar charts instead.
- **3D charts**: Never. They distort perception.
- **Dual-axis charts**: Use cautiously — can mislead.
- **Stacked bar (many categories)**: Hard to compare middle segments.

## Python Code Patterns

### Setup
```python
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

plt.style.use('seaborn-v0_8-whitegrid')
PALETTE = ['#4C72B0', '#DD8452', '#55A868', '#C44E52', '#8172B3', '#937860']
```

### Line Chart, Bar Chart, Histogram, Heatmap, Small Multiples
Patterns available for each with professional styling, proper labels, and export.

### Interactive Charts (Plotly)
```python
import plotly.express as px
fig = px.line(df, x='date', y='value', color='category', title='Trend')
fig.update_layout(hovermode='x unified')
fig.write_html('chart.html')
```

## Design Principles

### Color
- Use color purposefully to encode data, not decorate
- Highlight the story with accent color; grey everything else
- Sequential: single-hue gradient for ordered values
- Diverging: two-hue gradient for data with meaningful center
- Categorical: distinct hues, max 6-8
- Avoid red/green only (colorblind accessibility)

### Typography
- Title states the insight ("Revenue grew 23% YoY" not "Revenue by Month")
- Subtitle adds context (date range, filters, source)
- Axis labels readable (never rotated 90 degrees if avoidable)
- Data labels on key points only

### Layout
- Reduce chart junk (unnecessary gridlines, borders, backgrounds)
- Sort meaningfully (by value, not alphabetically)
- Appropriate aspect ratio (time series wider, comparisons squarer)
- White space is good

### Accuracy
- Bar charts always start at zero
- Consistent scales across panels
- Show uncertainty (error bars, confidence intervals)
- Label your axes

## Accessibility

### Color Blindness
- Never rely on color alone — add patterns, line styles, or direct labels
- Test with colorblind simulator
- Use `sns.color_palette("colorblind")`

### General
- Sufficient contrast between elements and background
- Text minimum 10pt labels, 12pt titles
- Include alt text describing the key finding
- Provide data table alternative
- Check if chart works in black and white
