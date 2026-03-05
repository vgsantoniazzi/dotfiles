---
name: recap
description: Quick project summary for returning after time away. Scans ai-notes, extracts task status, reviews recent context.
---

# Recap

Generate a quick project summary for returning after time away.

## Process

1. Scan `ai-notes/` directory structure to identify key topics
2. Extract task completion status from todo files using checkbox patterns
3. Review recent work context, decisions, and blockers
4. Output structured markdown

## Output Format

- **Project context**: What is this project about
- **Current state**: Status breakdown of tasks
- **Recent decisions**: What was decided and why
- **Assumptions needing validation**: Unverified assumptions
- **Operational notes**: Maintenance and monitoring considerations
- **Next actions**: Specific, actionable next steps
- **Open questions**: Unresolved items

## Principles

- Be terse - optimized for parallel project work
- Emphasize actionable next steps as starting points
- Surface unvalidated assumptions clearly
- Flag operational and maintenance considerations
- Use subagents to manage context efficiently

## Graceful Handling

Note when no `ai-notes/` directory or conversation context exists.
