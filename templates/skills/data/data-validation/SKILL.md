---
name: data-validation
description: QA an analysis before sharing with stakeholders — methodology checks, accuracy verification, and bias detection. Use when reviewing an analysis for errors, checking for survivorship bias, validating aggregation logic, or preparing documentation for reproducibility.
---

# Data Validation Skill

Pre-delivery QA checklist, common data analysis pitfalls, result sanity checking, and documentation standards for reproducibility.

## Pre-Delivery QA Checklist

### Data Quality Checks
- [ ] Source verification: Correct tables/data sources used
- [ ] Freshness: Data current enough, "as of" date noted
- [ ] Completeness: No unexpected gaps in time series or segments
- [ ] Null handling: Nulls handled appropriately
- [ ] Deduplication: No double-counting from bad joins or duplicates
- [ ] Filter verification: All WHERE clauses correct

### Calculation Checks
- [ ] Aggregation logic: GROUP BY correct, aggregation level matches grain
- [ ] Denominator correctness: Right denominator, non-zero
- [ ] Date alignment: Same time period lengths, partial periods excluded
- [ ] Join correctness: Appropriate JOIN types, no many-to-many inflation
- [ ] Metric definitions: Match stakeholder definitions
- [ ] Subtotals sum: Parts add up to whole (or explained why not)

### Reasonableness Checks
- [ ] Magnitude: Numbers in plausible range
- [ ] Trend continuity: No unexplained jumps or drops
- [ ] Cross-reference: Key numbers match other known sources
- [ ] Edge cases: Boundaries handled correctly

### Presentation Checks
- [ ] Chart accuracy: Bar charts at zero, axes labeled, consistent scales
- [ ] Number formatting: Appropriate precision, consistent formatting
- [ ] Title clarity: Titles state the insight, date ranges specified
- [ ] Caveat transparency: Limitations and assumptions stated
- [ ] Reproducibility: Someone else could recreate from documentation

## Common Pitfalls

### Join Explosion
Many-to-many join silently multiplies rows. Always check row counts after joins.

### Survivorship Bias
Analyzing only entities that exist today, ignoring churned/deleted/failed. Ask "who is NOT in this dataset?"

### Incomplete Period Comparison
Comparing partial to full periods. Filter to complete periods or compare same number of days.

### Denominator Shifting
Denominator changes between periods. Use consistent definitions across all compared periods.

### Average of Averages
Averaging pre-computed averages gives wrong results when group sizes differ. Always aggregate from raw data.

### Timezone Mismatches
Different sources using different timezones. Standardize to UTC before analysis.

### Selection Bias
Segments defined by the outcome you're measuring (circular logic). Define segments based on pre-treatment characteristics.

## Sanity Checking

### Magnitude Checks
| Metric Type | Check Against |
|---|---|
| User counts | Known MAU/DAU figures |
| Revenue | Known ARR |
| Conversion rates | 0-100%, dashboard figures |
| Growth rates | Is 50%+ MoM realistic? |
| Averages | Reasonable given distribution |
| Percentages | Sum to ~100% |

### Red Flags
- Metrics changing >50% period-over-period without obvious cause
- Exact round numbers (suggests filter/default issues)
- Rates at exactly 0% or 100%
- Results that perfectly confirm the hypothesis
- Identical values across periods/segments

## Documentation Template

```markdown
## Analysis: [Title]

### Question
[Specific question being answered]

### Data Sources
[Tables with "as of" dates]

### Definitions
[Metric and segment definitions]

### Methodology
[Step-by-step approach]

### Assumptions and Limitations
[With impact assessment]

### Key Findings
[With supporting evidence]

### SQL Queries
[All queries with comments]
```
