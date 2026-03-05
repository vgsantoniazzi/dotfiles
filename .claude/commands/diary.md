---
name: diary
description: Document this Claude session. Captures objectives, work done, decisions, and lessons learned with context-first approach.
---

# Session Diary

Review the conversation and extract a structured session diary.

## Process

1. Review the full conversation
2. Extract objectives, completed work, technical decisions
3. Capture operational considerations and lessons learned

## Session Metadata
- Timestamp
- Project
- Duration estimate

## Sections to Capture

### Objectives and Work Completed
Document what was intended and what was actually accomplished, including file changes.

### Technical Decisions
Record in table format: choice made, rationale, and how to reverse if needed.

### Operational Considerations
Address maintenance ownership, failure detection, and observability.

### Assumptions
Separate user-confirmed items from implicit inferences requiring validation.

### Challenges and Lessons
Treat failures as learning opportunities.

### Patterns Worth Encoding
Flag patterns for updating CLAUDE.md.

## Storage
Save entries to `~/.claude/memory/diary/YYYY-MM-DD-N.md` using date and session number.
