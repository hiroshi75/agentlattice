---
name: data-exploration
description: Profile and explore datasets to understand their shape, quality, and patterns before analysis. Use when encountering a new dataset, assessing data quality, discovering column distributions, identifying nulls and outliers, or deciding which dimensions to analyze.
---

# Data Exploration Skill

Systematic methodology for profiling datasets, assessing data quality, discovering patterns, and understanding schemas.

## Data Profiling Methodology

### Phase 1: Structural Understanding
- How many rows and columns?
- What is the grain (one row per what)?
- What is the primary key? Is it unique?
- When was the data last updated?
- How far back does the data go?

**Column classification**: Categorize each column as Identifier, Dimension, Metric, Temporal, Text, Boolean, or Structural.

### Phase 2: Column-Level Profiling

**All columns**: Null count/rate, distinct count, cardinality ratio, most/least common values.

**Numeric**: min, max, mean, median, standard deviation, percentiles (p1, p5, p25, p75, p95, p99), zero count, negative count.

**String**: min/max/avg length, empty string count, pattern analysis, case consistency, whitespace.

**Date/timestamp**: min/max date, null dates, future dates, distribution by period, gaps.

### Phase 3: Relationship Discovery
- Foreign key candidates
- Hierarchies (country > state > city)
- Correlations between numeric columns
- Derived/redundant columns

## Quality Assessment Framework

### Completeness Score
- **Complete** (>99%): Green
- **Mostly complete** (95-99%): Yellow
- **Incomplete** (80-95%): Orange
- **Sparse** (<80%): Red

### Consistency Checks
- Value format inconsistency ("USA", "US", "United States")
- Type inconsistency (numbers as strings)
- Referential integrity violations
- Business rule violations (negative quantities, end < start)
- Cross-column inconsistency (status="completed" but completed_at is null)

### Accuracy Red Flags
- Placeholder values (0, -1, 999999, "N/A", "TBD")
- Suspiciously high frequency of a single value
- Stale data (no recent updates)
- Impossible values (age > 150, future dates)
- Round number bias

## Pattern Discovery

### Distribution Analysis
Characterize as: Normal, Right-skewed, Left-skewed, Bimodal, Power law, Uniform.

### Temporal Patterns
Look for: Trend, Seasonality, Day-of-week effects, Holiday effects, Change points, Anomalies.

### Segmentation Discovery
Find natural segments by comparing metric distributions across categorical columns with 3-20 distinct values.

### Correlation Exploration
Flag strong correlations (|r| > 0.7) for investigation. Note: correlation does not imply causation.

## Schema Documentation Template

```markdown
## Table: [schema.table_name]

**Description**: [What this table represents]
**Grain**: [One row per...]
**Primary Key**: [column(s)]
**Row Count**: [approximate, with date]
**Update Frequency**: [real-time / hourly / daily / weekly]

### Key Columns
| Column | Type | Description | Example Values | Notes |
|--------|------|-------------|----------------|-------|

### Relationships
[Joins and foreign keys]

### Known Issues
[Data quality issues and gotchas]
```
