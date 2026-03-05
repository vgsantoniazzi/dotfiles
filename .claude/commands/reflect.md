---
name: reflect
description: Analyze diary entries to identify patterns and propose CLAUDE.md updates. Detects rule violations, operational lessons, and synthesizes insights.
---

# Reflect on Diary Entries

Analyze diary entries to identify patterns and propose CLAUDE.md updates.

## Process

1. **Check processed entries log** at `~/.claude/memory/reflections/processed.log`
2. **Locate diary files** in `~/.claude/memory/diary/`
3. **Filter based on parameters** (date range, project, etc.)
4. **Read current CLAUDE.md rules**
5. **Analyze for patterns**

## Priority Order

### 1. Rule Violations (HIGH PRIORITY)
Check if diary entries show instances where Claude violated existing CLAUDE.md rules.
These require rule strengthening, not new additions.

### 2. Operational Lessons
- Production incidents and root causes
- Debugging patterns that worked
- Observability gaps discovered
- Maintenance burden surprises

### 3. Assumption Failures
- Implicit assumptions that proved wrong
- Context that should have been asked upfront

## Pattern Recognition Standards

- **2+ occurrences**: Pattern is actionable
- **3+ occurrences**: Strong pattern
- **Signal**: Universal or repeated preferences
- **Noise**: One-off requests or context-specific tasks

## CLAUDE.md Update Requirements

Rules must be:
- Succinct and actionable
- Organized by category
- Written as imperatives: "use X" or "avoid Y"
- Brief bullet points, no verbose explanations
- Grounded in real incidents, not theory

## Output Format

Save reflection documents as `YYYY-MM-reflection-N.md` in `~/.claude/memory/reflections/`:

```markdown
# Reflection - [Date]

## Rule Violations Detected
- [Existing rule]: [How it was violated]
  - **Strengthening:** [Proposed rule update]

## Operational Lessons
- [Incident]: [What we learned]
  - **New rule:** [If warranted]

## Assumption Failures
- [What was assumed]: [What was actually true]
  - **Prevention:** [How to avoid]

## Patterns Observed
- [Pattern]: [Evidence from N entries]

## Proposed CLAUDE.md Updates
[New or updated rules - brief, actionable]
```

## Processing Log Format

Track analyzed entries in `processed.log`:
```
[diary-filename] | [reflection-date] | [reflection-filename]
```

## Anti-Patterns to Flag
- Things that consistently caused problems
