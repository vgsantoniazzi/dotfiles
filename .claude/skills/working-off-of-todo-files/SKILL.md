---
name: working-off-of-todo-files
description: Work systematically through todo files. One task at a time, explicit status updates, wait for permission between tasks.
---

# Working Off Todo Files

Work systematically with `ai-notes/**/*/todo.{md,txt}` files.

## Core Principles

1. **One Task at a Time** - Complete or explicitly block before moving on
2. **Explicit Status** - Update markers as you work
3. **User Control** - Wait for permission between tasks
4. **Operator Mindset** - Consider maintenance, rollback, observability

## Task Format

```markdown
## Context
Brief overview of what we're building and why

## Tasks

- [ ] Task 1: Clear description
    Additional context indented 4 spaces
    Constraints or requirements

- [/] Task 2: Currently in progress
    Progress notes here

- [x] Task 3: Completed
    What was done, any notes for future
```

## Task States

- `- [ ]` Pending
- `- [/]` In Progress
- `- [x]` Completed

## Working Protocol

### Before Starting a Task
1. Read entire file for context
2. Identify next uncompleted task (first `- [ ]`)
3. Think through subtasks mentally (don't write them)
4. Announce: "Starting Task N: [description]"
5. Mark as in-progress: `- [ ]` → `- [/]`

### During Execution
- Work systematically
- Add progress notes (indented under task)
- Document blockers immediately
- Stay focused on current task only

### After Completion
1. Verify requirements met
2. Run relevant tests
3. Consider: rollback path? observability?
4. Mark complete: `- [/]` → `- [x]`
5. Add completion notes
6. **STOP and wait for user**

### Communication
Always state:
- Which task you're starting
- Key decisions or assumptions
- Any blockers
- When complete
- Request permission to continue

```
"Completed Task 2: Added retry logic to webhook delivery.
Tests pass. Logging added for failed attempts.
Should I proceed to Task 3?"
```

## Internal Workflow

Follow these steps internally (don't add subtasks to the todo file):

### Feature Implementation
1. Understand requirements
2. Check existing patterns
3. Write tests first
4. Implement
5. Verify
6. Consider operational needs

### Bug Fix
1. Reproduce with test
2. Verify test fails
3. Fix minimally
4. Verify test passes
5. Check for regressions
6. Document root cause

## Operator Considerations

Before marking complete, ask:
- Who maintains this?
- How do we know it's working?
- How do we know it's broken?
- Can we roll back?
- Is there observability?

## Do's

- Focus completely on one task
- Update status markers immediately
- Wait for permission between tasks
- Add operational notes
- Document blockers clearly

## Don'ts

- Jump between tasks
- Continue without permission
- Skip status updates
- Ignore operational concerns
- Leave tasks half-done without notes
