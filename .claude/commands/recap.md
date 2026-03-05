---
name: recap
description: Generate a quick recap for someone returning to this project after time away. Focus on state, decisions, and next actions.
---

# Recap Command

Generate a quick recap for someone returning to this project.

## Process

1. **Scan ai-notes/ directory** (if exists at project root):
   - List all files to understand project structure
   - Note file names - they often indicate key topics/features

2. **Extract task status from todo files**:
   - Find files matching `ai-notes/**/*/todo.{txt,md}`
   - Extract lines matching `- [ ]`, `- [x]`, `- [/]`
   - Use subagent for deeper context if needed

3. **Review recent conversation** (if any):
   - What was being worked on
   - Key decisions made
   - Assumptions that need validation
   - Blockers or open questions

4. **Produce condensed recap**:

```markdown
## Recap

**Context:** [1-2 sentences: what is this project/feature about]

**Current state:**
- [what's done]
- [what's in progress]
- [what's blocked]

**Recent decisions:**
- [decision]: [rationale]
- [decision]: [rationale]

**Assumptions to validate:**
- [assumption that was made without explicit confirmation]

**Operational notes:**
- [any observability gaps]
- [maintenance considerations]
- [technical debt introduced]

**Next actions:**
- [ ] [specific actionable next step]
- [ ] [another next step]

**Open questions:**
- [blockers or decisions pending]
```

## Key Principles

- **Be terse** - User works on parallel projects and needs quick pointers
- **Focus on next actions** - That's the starting point for the next prompt
- **Surface assumptions** - Highlight what needs validation
- **Note operational state** - Any monitoring gaps or maintenance needs
- If no ai-notes/ exists and no conversation context, say so briefly
- Use subagents to read files to avoid context bloat
