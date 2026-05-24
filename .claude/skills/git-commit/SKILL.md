---
name: git-commit
description: Stage and commit changes with clear, structured messages. Problem-solution-future format. Never commit without this skill.
---

# Git Commit Workflow

Stage changes and create commits with clear, structured messages.

## When to Use

Activate when the user:
- Asks to commit changes
- Says "commit", "save this", "commit and push"
- Completes work and wants to save

## Commit Message Format

```
Capitalized, short (50 chars or less) summary

More detailed explanatory text, wrapped to 80 characters.
Write in imperative mood: "Fix bug" not "Fixed bug".
```

## Message Structure

### Paragraph 1: The Problem
What was the problem BEFORE this commit? What impact did it have?
If there's an obvious objection ("why not just X?"), acknowledge it briefly.

### Paragraph 2: The Solution
What does this commit do to solve the problem?
Write as prose: "This commit...", "This change..."
Be concise - don't repeat what the code shows.

### Paragraph 3: Future/Trade-offs (Optional)
What's the ideal solution if different from this?
What could be improved later?
What trade-offs were made?

## Examples

### Bug Fix
```
Fix race condition in payment processing

When two requests hit the payment endpoint simultaneously, both could pass
the idempotency check before either wrote to the database. This caused
duplicate charges roughly once per 10k transactions.

This change wraps the check-and-write in a database transaction with row-level
locking. It also adds an index on the idempotency key to keep the lock fast.

A distributed lock would handle cross-server races better, but our current
single-database setup makes this sufficient for now.
```

### Feature
```
Add retry button to failed export jobs

Users had no way to retry a failed export without re-entering all parameters.
Support tickets about this increased after we added larger export types.

This commit adds a retry action to the exports controller that clones the
original job's parameters. The button appears on the job status page for
failed jobs only.
```

### Refactoring
```
Move EmailValidator to Notifications namespace

The EmailValidator class handles email format, delivery status, and bounce
handling - all specific to notifications. Its generic name and top-level
location made it look like a general-purpose utility.

This commit moves the class under Notifications namespace and updates the
three call sites in mailer classes.
```

## Pre-Commit Checks (MANDATORY)

**ALWAYS run auto-fix linters on staged files before committing. No exceptions.**

```bash
# Ruby/Rails — auto-fix staged .rb files, then re-stage
dip bundle exec rubocop -a $(git diff --cached --name-only -- '*.rb')
git add $(git diff --cached --name-only -- '*.rb')

# JavaScript/TypeScript — auto-fix staged files, then re-stage
npx eslint --fix $(git diff --cached --name-only -- '*.ts' '*.tsx' '*.js' '*.jsx')
git add $(git diff --cached --name-only -- '*.ts' '*.tsx' '*.js' '*.jsx')
```

If offenses remain after auto-fix, fix them manually before committing. Never commit with linter violations.

## Workflow

```bash
# Stage changes
git add [files]

# Commit with multi-paragraph message
git commit \
  -m "Summary line" \
  -m "Problem paragraph" \
  -m "Solution paragraph"

# Or with heredoc for complex messages
git commit -m "$(cat <<'EOF'
Summary line here

First paragraph explaining the problem.

Second paragraph explaining the solution.
EOF
)"
```

## Branch Naming Convention

When creating branches, use the format: `vgsa/<descriptive-slug>`

Examples:
- `vgsa/fix-email-notification-visa-galileo`
- `vgsa/add-retry-button-exports`
- `vgsa/refactor-payment-processor`

Rules:
- Prefix: always `vgsa/`
- Suffix: lowercase, hyphen-separated description of the change
- Keep it concise but descriptive enough to understand the PR purpose

## Rules

- **Always run linters before committing** (rubocop for Ruby, eslint for JS/TS)
- Do NOT push without user confirmation
- Keep summary under 50 characters
- Wrap body at 80 characters
- Use imperative mood
- Focus on WHY, not just WHAT
- **NEVER include Co-Authored-By or AI attribution lines** - the commit stands on its own
- **NEVER ask to merge the PR** - the user will merge via GitHub directly

## After Committing

Tell the user what was committed (summary line).
Ask if they want to push.

## After Pushing

Always return the branch URL so the user can open the PR themselves:

```
https://github.com/<org>/<repo>/compare/<branch>?expand=1
```

Example output:
```
Pushed to `vgsa/fix-email-notification-visa-galileo`

Open PR: https://github.com/tremendous/core/compare/vgsa/fix-email-notification-visa-galileo?expand=1
```

**Do NOT offer to create the PR** - the user will review and open it themselves.
