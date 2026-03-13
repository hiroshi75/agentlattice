---
name: data-context-extractor
description: Capture and codify company-specific data knowledge — entity definitions, metric formulas, table schemas, and tribal knowledge. Use when onboarding to a new data environment, documenting institutional data knowledge, or building a data dictionary.
---

# Data Context Extractor

A meta-skill for capturing and codifying company-specific data knowledge. Helps organizations document tribal knowledge about their data — entity definitions, metric formulas, table schemas, and common analyst pitfalls.

## Two Operating Modes

### Bootstrap Mode
Initialize new data analysis skills from scratch:

1. **Database Connection**: Identify warehouse type (BigQuery, Snowflake, PostgreSQL, Databricks) and explore schemas/tables
2. **Critical Questions**: Capture tribal knowledge through targeted prompts
3. **Skill Generation**: Produce organized documentation
4. **Packaging**: Deliver complete skill structure with reference files

### Iteration Mode
Enhance existing skills by adding domain-specific context:

1. Identify gaps in existing documentation
2. Ask targeted questions about specific data domains
3. Update reference materials accordingly

## Critical Questions to Capture

### Entity Definitions
- What are the core business entities? (users, accounts, orders, events)
- How is each entity uniquely identified?
- What are the lifecycle states for each entity?
- When is an entity created, updated, or archived?

### Metric Definitions
- What are the key business metrics?
- How is each metric calculated exactly? (formula, filters, time windows)
- What are the known edge cases or gotchas in each metric?
- Who is the source of truth for metric definitions?

### Data Quality
- What are known data quality issues?
- Which tables are trustworthy vs. "use with caution"?
- What time delays exist between events and data availability?
- Are there known gaps or missing data periods?

### Common Analyst Pitfalls
- What mistakes do new analysts commonly make?
- What join traps exist (many-to-many, missing records)?
- What timezone issues should analysts be aware of?
- What definitional ambiguities cause confusion?

### Business Context
- What does a typical customer journey look like in the data?
- How do business processes map to database tables?
- What external events affect the data (launches, outages, migrations)?
- What seasonal patterns should analysts know about?

## Output Structure

```
skill/
  SKILL.md           # Main skill file with overview and instructions
  references/
    entities.md      # Entity definitions and relationships
    metrics.md       # Metric formulas and definitions
    tables.md        # Table schemas and descriptions
    gotchas.md       # Common pitfalls and data quality notes
    glossary.md      # Business terminology
```

## Tips

- Run Bootstrap Mode when first setting up a data team or onboarding to a new data environment
- Run Iteration Mode after discovering a new gotcha, adding a new data source, or when new team members identify documentation gaps
- Keep the output as reference material alongside your analysis skills
