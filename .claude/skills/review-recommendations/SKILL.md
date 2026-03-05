---
name: review-recommendations
description: Critically evaluate technical recommendations before presenting them. If you'd fold immediately when challenged, don't present it.
---

# Review Recommendations

Critically evaluate technical recommendations before presenting them to users.

## Core Principle

> If you'd fold immediately when challenged on a recommendation, you shouldn't present it in the first place.

## When to Use

Before suggesting:
- Performance optimizations
- Configuration changes
- Architecture decisions
- "Best practices"
- Any change that affects how systems work

## Review Framework

For each recommendation, evaluate:

### 1. Problem Verification
- Does an actual problem exist?
- What's the measurable evidence?
- Is the current state actually bad?

### 2. Context Alignment
- Does this fit the user's specific infrastructure?
- What tools are already in place?
- Could existing solutions already handle this?

### 3. Assumption Exposure
- What unstated assumptions underlie this recommendation?
- Are these assumptions valid for this context?

### 4. Confidence Assessment
- Would you defend this to an expert?
- What's the confidence level (LOW/MEDIUM/HIGH)?
- What evidence supports this recommendation?

### 5. Disposition Decision
- **KEEP**: Strong evidence, context-appropriate
- **MODIFY**: Good idea, needs adjustment for context
- **DISCARD**: Generic advice, not context-specific

## Red Flag Language

Avoid these patterns:
- "Here are N things you could improve"
- "Best practices suggest..."
- "You should consider..."
- Multiple suggestions without context verification

## Output Format

Only present recommendations that pass review:

```markdown
## Recommendation: [Title]

**Problem:** [Verified problem with evidence]
**Context:** [Why this applies to user's situation]
**Suggestion:** [Specific, actionable recommendation]
**Confidence:** HIGH | MEDIUM
**Trade-offs:** [What this costs or risks]
```

## Anti-Pattern Example

Bad:
> "You could add cache mounts to speed up CI builds"

This fails because:
- No verification that CI builds are slow
- No check if caching is already in place
- Generic advice not specific to context

Good:
> "Your CI builds are taking 8 minutes, with 5 minutes spent on bundle install. Adding cache mounts for vendor/bundle could reduce this to ~2 minutes. You're using GitHub Actions which supports this natively."

## Operator Lens

Before presenting any recommendation, also ask:
- Who maintains this if implemented?
- What's the operational burden?
- Is this adding complexity they don't need?
- Would patio11 call this hype-driven?
- Would Joel Spolsky say this is a rewrite in disguise?

The user is skeptical of:
- Trend-driven architecture
- Generic "best practices"
- Cleverness masquerading as sophistication
- "Web scale" solutions without real scale
