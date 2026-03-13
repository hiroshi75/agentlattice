---
name: metrics-tracking
description: Define, track, and analyze product metrics with frameworks for goal setting and dashboard design. Use when setting up OKRs, building metrics dashboards, running weekly metrics reviews, identifying trends, or choosing the right metrics for a product area.
---

# Metrics Tracking Skill

You are an expert at product metrics — defining, tracking, analyzing, and acting on product metrics. You help product managers build metrics frameworks, set goals, run reviews, and design dashboards that drive decisions.

## Product Metrics Hierarchy

### North Star Metric
The single metric that best captures the core value your product delivers to users. It should be:
- **Value-aligned**: Moves when users get more value from the product
- **Leading**: Predicts long-term business success
- **Actionable**: The product team can influence it
- **Understandable**: Everyone in the company can understand it

### L1 Metrics (Health Indicators)
The 5-7 metrics that together paint a complete picture of product health:

- **Acquisition**: New signups, signup conversion rate, channel mix, CPA
- **Activation**: Activation rate, time to activate, setup completion rate
- **Engagement**: DAU/WAU/MAU, stickiness (DAU/MAU), core action frequency
- **Retention**: D1/D7/D30 retention, cohort curves, churn rate
- **Monetization**: Free to paid conversion, MRR/ARR, ARPU, expansion revenue, net revenue retention
- **Satisfaction**: NPS, CSAT, support ticket volume

### L2 Metrics (Diagnostic)
Detailed metrics for investigating L1 changes:
- Funnel conversion at each step
- Feature-level usage and adoption
- Segment-specific breakdowns
- Performance metrics (load time, error rate)

## Goal Setting Frameworks

### OKRs (Objectives and Key Results)

**Objectives**: Qualitative, aspirational goals.
**Key Results**: Quantitative measures of success. 2-4 per Objective.

**Example**:
```
Objective: Make our product indispensable for daily workflows

Key Results:
- Increase DAU/MAU ratio from 0.35 to 0.50
- Increase D30 retention for new users from 40% to 55%
- 3 core workflows with >80% task completion rate
```

### OKR Best Practices
- 70% completion is the target for stretch OKRs
- Key Results should measure outcomes, not outputs
- 2-3 objectives with 2-4 KRs each is plenty
- Review at mid-period, grade honestly at end

## Metric Review Cadences

### Weekly Metrics Check (15-30 min)
- North Star metric: current value, WoW change
- Key L1 metrics: any notable movements
- Active experiments: results and significance
- Anomalies: unexpected spikes or drops

### Monthly Metrics Review (30-60 min)
- Full L1 metric scorecard with MoM trends
- Progress against quarterly OKR targets
- Cohort analysis: newer cohorts performing better?
- Feature adoption: recent launches performing?

### Quarterly Business Review (60-90 min)
- OKR scoring for the quarter
- Trend analysis for all L1 metrics
- Year-over-year comparisons
- Set OKRs for next quarter

## Dashboard Design Principles

1. **Start with the question, not the data**
2. **Hierarchy of information**: North Star at top, L1 next, L2 on drill-down
3. **Context over numbers**: Always show comparison (prior period, target, benchmark)
4. **Fewer metrics, more insight**: Focus on 5-10 that matter
5. **Consistent time periods**
6. **Visual status indicators**: Green/Yellow/Red
7. **Actionability**: Every metric should be something the team can influence

### Dashboard Anti-Patterns
- Vanity metrics that always go up
- Too many metrics requiring scrolling
- Raw numbers without context
- Stale dashboards not reviewed in months
- Output dashboards measuring team activity instead of user outcomes
