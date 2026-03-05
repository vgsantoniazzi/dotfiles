---
name: write-task
description: Write clear, actionable tasks for project management tools. Focus on constraints, acceptance criteria, and operational concerns.
---

# Write Task Skill

Write clear, actionable tasks for project management tools (Linear, Asana, etc.).

## Templates

### Short Template (Simple Work)

```markdown
## [Task Title]

**Goal:** [One sentence - what does "done" look like?]

**Acceptance Criteria:**
- [ ] [Specific, testable]
- [ ] [Another criterion]
- [ ] Tests pass

**Notes:** [Constraints, context, links]
```

### Full Template (Complex Work)

```markdown
## [Task Title]

### Background
[Why does this matter? What's the context?]
[What's been tried? What do we know?]

### Goal
[What does success look like?]

### Constraints
- [Hard requirements]
- [Time/resource limits]
- [Dependencies]

### Approach (if known)
[Recommended path]
[Key decisions]

### Acceptance Criteria
- [ ] [Specific, testable]
- [ ] [Another]
- [ ] Tests pass
- [ ] Rollback path documented

### Operational Concerns
- [ ] How do we know it's working?
- [ ] How do we know it's broken?
- [ ] Who maintains this?

### Open Questions
- [Things to clarify]

### Out of Scope
- [Explicitly what this does NOT include]
```

## Title Guidelines

### Good Titles
- "Add retry button to failed export jobs"
- "Fix: duplicate charges on concurrent requests"
- "Investigate: dashboard slow for accounts with 10k+ records"

### Bad Titles
- "Improve performance" (vague)
- "Fix bug" (which bug?)
- "Implement feature from Slack thread" (no context)

## Writing Principles

### Background
- Progress from high-level to specific
- Include why this matters (business context)
- Reference prior work or decisions

### Acceptance Criteria
- Specific and testable
- Include "tests pass"
- Include operational criteria when relevant
- Avoid "and" - split into separate criteria

### Language
- Be direct
- Avoid jargon
- Include specific examples
- Use imperative: "Add X" not "X should be added"

## Operational Criteria

For tasks that touch production, include:
- How to verify it works
- How to detect if it breaks
- Rollback plan if applicable
- Monitoring/alerting needs
