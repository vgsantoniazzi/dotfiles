---
name: help-me-spec
description: Launch a pragmatic specification interview. Focuses on constraints, edge cases, operational concerns, and MVP scope. Avoids over-engineering.
---

# Help Me Spec

Launch a subagent that interviews the user to create a pragmatic specification.

## Argument Handling

- **URL** (contains `http://` or `https://`): Use WebFetch to load as context
- **File path** (starts with `/`, `./`, `~`): Use Read to load as context
- **Plain text**: Use directly as starting context
- **Empty**: Ask the user what they want to spec

## Interview Philosophy

The user is a Distinguished Engineer with operator mindset. They value:
- Pragmatism over purity
- MVP over comprehensive
- Operational clarity over feature completeness
- Business value over technical elegance

Do NOT over-engineer the spec. Focus on what's needed to ship safely.

## Interview Process

### 1. Understand Context First
Before questions, scan the codebase:
- What already exists?
- What patterns are established?
- What's the operational environment?

### 2. Core Questions (Always Ask)
- What's the simplest version that delivers value?
- What are the hard constraints (data, time, resources)?
- What's the rollback plan if this fails?
- Who will maintain this?
- How will we know it's working? (observability)

### 3. Technical Implementation (Adapt to Scope)
- Edge cases that WILL happen (not theoretical)
- Data integrity requirements
- Failure modes and recovery
- Integration with existing systems
- Idempotency requirements

### 4. Operational Concerns
- How do we deploy this safely?
- How do we monitor it?
- What breaks if this breaks?
- Can we roll back?

### 5. Business Context
- What's the ROI?
- What's the cost of not doing this?
- Who are the actual users?
- What does success look like?

## Interview Protocol

1. Acknowledge context, ask FIRST question
2. Use AskUserQuestion for every question (2-4 options + custom)
3. Build on previous answers - no generic questions
4. Probe deeper on short answers
5. Explicitly ask: "What am I missing?"
6. Periodically summarize

## Question Guidelines

- DO NOT ask obvious questions
- DO ask about edge cases that will happen
- DO ask about failure modes
- DO ask about rollback
- Prefer specific to broad
- Skip questions the codebase already answers

## Completion

1. Determine where to save:
   - If `./ai-notes` exists: `./ai-notes/specs/[feature-name].md` (create `specs/` if needed)
   - Otherwise: ask user, suggest `./spec.md`

2. Write spec with ONLY relevant sections:
   - Overview (1-2 sentences)
   - Constraints (hard requirements)
   - MVP Scope (what's in, what's out)
   - Technical Approach
   - Edge Cases (real ones, not theoretical)
   - Failure Modes & Recovery
   - Rollback Plan
   - Observability Requirements
   - Open Questions
   - Out of Scope (explicitly)

3. Show spec, ask for adjustments

## Usage

```
/help-me-spec Add retry logic for failed webhook deliveries
/help-me-spec https://linear.app/org/issue/123
/help-me-spec ./notes/feature-idea.md
/help-me-spec
```
