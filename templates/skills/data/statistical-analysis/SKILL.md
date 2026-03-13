---
name: statistical-analysis
description: Apply statistical methods including descriptive stats, trend analysis, outlier detection, and hypothesis testing. Use when analyzing distributions, testing for significance, detecting anomalies, computing correlations, or interpreting statistical results.
---

# Statistical Analysis Skill

Descriptive statistics, trend analysis, outlier detection, hypothesis testing, and guidance on when to be cautious about statistical claims.

## Descriptive Statistics

### Central Tendency
| Situation | Use | Why |
|---|---|---|
| Symmetric distribution, no outliers | Mean | Most efficient estimator |
| Skewed distribution | Median | Robust to outliers |
| Categorical or ordinal data | Mode | Only option for non-numeric |
| Highly skewed with outliers | Median + mean | Gap shows skew |

Always report mean and median together for business metrics.

### Spread and Variability
- **Standard deviation**: For normally distributed data
- **IQR**: Robust to outliers, for skewed data
- **Coefficient of variation**: Compare variability across different scales
- **Range**: Quick sense of data extent

### Key Percentiles
p1 (floor), p5 (low normal), p25 (Q1), p50 (median), p75 (Q3), p90 (power users), p95 (high normal), p99 (extreme)

## Trend Analysis

### Moving Averages
- 7-day: smooths weekly seasonality
- 28-day: smooths weekly AND monthly patterns

### Period Comparisons
- WoW, MoM, YoY (gold standard for seasonal businesses)

### Growth Rates
- Simple: (current - previous) / previous
- CAGR: (ending / beginning) ^ (1/years) - 1

### Forecasting (Simple Methods)
- Naive: tomorrow = today (baseline)
- Seasonal naive: tomorrow = same day last week/year
- Linear trend: fit a line (only for clearly linear trends)
- Moving average: trailing average as forecast

Always communicate uncertainty as ranges, not point estimates.

## Outlier Detection

### Methods
- **Z-score**: |z| > 3 for normally distributed data
- **IQR**: Below Q1 - 1.5*IQR or above Q3 + 1.5*IQR
- **Percentile**: Below p1 or above p99

### Handling Outliers
Do NOT automatically remove. Instead:
1. Investigate: data error, genuine extreme, or different population?
2. Data errors: fix or remove
3. Genuine extremes: keep, use robust statistics
4. Different population: segment for separate analysis
5. Report what you did

## Hypothesis Testing

### When to Use
A/B test results, before/after comparisons, segment comparisons.

### Common Tests
| Scenario | Test |
|---|---|
| Compare two group means | t-test (independent) |
| Compare two proportions | z-test for proportions |
| Paired measurements | Paired t-test |
| Compare 3+ group means | ANOVA |
| Non-normal data | Mann-Whitney U test |
| Categorical association | Chi-squared test |

### Practical vs Statistical Significance
A difference can be statistically significant but practically meaningless. Always report:
- **Effect size**: How big is the difference?
- **Confidence interval**: Range of plausible effects
- **Business impact**: What does this mean in revenue, users, etc.?

## When to Be Cautious

### Correlation Is Not Causation
Consider reverse causation, confounding variables, and coincidence.

### Multiple Comparisons
Testing 20 metrics at p=0.05 means ~1 will be falsely significant. Adjust with Bonferroni or report number of tests.

### Simpson's Paradox
Aggregated trends can reverse when segmented. Always check key segments.

### Survivorship Bias
Analyzing only survivors ignores churned/failed entities. Ask "who is missing?"

### False Precision
Use ranges, not exact numbers. "About 5%" is more honest than "4.73%".
