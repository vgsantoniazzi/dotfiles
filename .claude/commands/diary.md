---
name: diary
description: Generate a structured diary entry documenting the current session. Captures objectives, work completed, technical decisions, operational considerations, and lessons learned.
---

# Session Diary Entry

Generate a structured diary entry documenting this session.

## Methodology

1. **Context-First Approach**: Review the active conversation to capture:
   - User objectives
   - Work completed
   - Technical decisions made
   - Operational considerations addressed
   - Assumptions made (explicit vs implicit)

2. **Fallback**: If conversation context is insufficient, locate and parse `.jsonl` session files in `~/.claude/projects/`

## Entry Structure

```markdown
# Session Diary - [Date]

## Session Metadata
- **Date/Time:** [timestamp]
- **Project:** [project name/path]
- **Duration:** [approximate]

## Objectives
What the user wanted to accomplish this session.

## Work Completed
- [Bullet points of accomplishments]
- [Include file modifications]
- [Note rollback considerations addressed]

## Technical Decisions
| Decision | Rationale | Rollback Path |
|----------|-----------|---------------|
| [choice] | [why] | [how to undo] |

## Operational Considerations
- [Who maintains this?]
- [How do we know it's broken?]
- [Observability added?]

## Assumptions Made
- **Explicit:** [user confirmed]
- **Implicit:** [I assumed - needs validation]

## Challenges & Solutions
- **Challenge:** [what went wrong]
  **Root cause:** [why it happened]
  **Solution:** [how it was resolved]
  **Prevention:** [how to avoid next time]

## Lessons for CLAUDE.md
- [Patterns worth encoding]
- [Rules that should be added]

## Notes for Future Sessions
- [Things to remember]
- [Unfinished work]
- [Technical debt introduced]
```

## Key Emphasis

1. **Capture reasoning** - Document WHY decisions were made, not just what
2. **Operational lens** - Note maintenance burden and observability
3. **Learning opportunities** - Include failures as learning
4. **Rollback paths** - Document how to undo major changes
5. **Assumptions** - Distinguish explicit from implicit

## Storage

Save entries to `~/.claude/memory/diary/YYYY-MM-DD-N.md` where N is the session number for that day.
