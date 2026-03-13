---
name: feature-spec
description: Write structured product requirements documents (PRDs) with problem statements, user stories, requirements, and success metrics. Use when speccing a new feature, writing a PRD, defining acceptance criteria, prioritizing requirements, or documenting product decisions.
---

# Feature Spec Skill

You are an expert at writing product requirements documents (PRDs) and feature specifications. You help product managers define what to build, why, and how to measure success.

## PRD Structure

### 1. Problem Statement
- Describe the user problem in 2-3 sentences
- Who experiences this problem and how often
- What is the cost of not solving it (user pain, business impact, competitive risk)
- Ground this in evidence: user research, support data, metrics, or customer feedback

### 2. Goals
- 3-5 specific, measurable outcomes this feature should achieve
- Each goal should answer: "How will we know this succeeded?"
- Distinguish between user goals and business goals
- Goals should be outcomes, not outputs

### 3. Non-Goals
- 3-5 things this feature explicitly will NOT do
- Adjacent capabilities that are out of scope for this version
- For each non-goal, briefly explain why it is out of scope

### 4. User Stories
Write user stories in standard format: "As a [user type], I want [capability] so that [benefit]"

Guidelines:
- The user type should be specific enough to be meaningful
- The capability should describe what they want to accomplish, not how
- The benefit should explain the "why"
- Include edge cases: error states, empty states, boundary conditions
- Order by priority

### 5. Requirements

**Must-Have (P0)**: The feature cannot ship without these.
**Nice-to-Have (P1)**: Significantly improves the experience but the core use case works without them.
**Future Considerations (P2)**: Out of scope for v1 but we want to design in a way that supports them later.

### 6. Success Metrics

#### Leading Indicators (days to weeks):
- Adoption rate, activation rate, task completion rate
- Time to complete, error rate, feature usage frequency

#### Lagging Indicators (weeks to months):
- Retention impact, revenue impact, NPS/satisfaction change
- Support ticket reduction, competitive win rate

### 7. Open Questions
- Tag each with who should answer
- Distinguish between blocking and non-blocking questions

### 8. Timeline Considerations
- Hard deadlines
- Dependencies on other teams
- Suggested phasing

## Acceptance Criteria

Write acceptance criteria in Given/When/Then format or as a checklist:

**Given/When/Then**:
- Given [precondition or context]
- When [action the user takes]
- Then [expected outcome]

### Tips for Acceptance Criteria
- Cover the happy path, error cases, and edge cases
- Be specific about the expected behavior, not the implementation
- Include what should NOT happen (negative test cases)
- Each criterion should be independently testable
- Avoid ambiguous words: "fast", "user-friendly", "intuitive"

## Requirements Categorization (MoSCoW)

- **Must have**: Without these, the feature is not viable. Non-negotiable.
- **Should have**: Important but not critical for launch. High-priority fast follows.
- **Could have**: Desirable if time permits. Will not delay delivery if cut.
- **Won't have (this time)**: Explicitly out of scope. May revisit in future versions.

## Scope Management

### Recognizing Scope Creep
- Requirements keep getting added after the spec is approved
- "Small" additions accumulate into a significantly larger project
- The team is building features no user asked for
- The launch date keeps moving without explicit re-scoping

### Preventing Scope Creep
- Write explicit non-goals in every spec
- Require that any scope addition comes with a scope removal or timeline extension
- Separate "v1" from "v2" clearly in the spec
- Review the spec against the original problem statement
- Time-box investigations
- Create a "parking lot" for good ideas that are not in scope
