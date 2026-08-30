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

Resolve `DIR` and `LINT` per language from `~/.claude/shared/project-checks.md`.
Never hardcode a runner here; this skill runs in every repo.

Run once per touched sub-project. It lints only what is staged, and does
nothing when nothing is staged.

Bind `DIR` and `LINT` explicitly first. If either is unset the block below
lints nothing and still exits 0, which is worse than failing.

```bash
: "${DIR:?resolve DIR from the project first}"
: "${LINT:?resolve LINT from the project first}"
cd "$(git rev-parse --show-toplevel)/$DIR" || exit 1
files=$(git diff --cached --name-only --relative --diff-filter=ACMR -- '*.rb')
if [ -z "$files" ]; then
  echo "no staged .rb in $DIR, skipping"
else
  echo "$files" | xargs $LINT && echo "$files" | xargs git add
fi
```

Same shape for JS/TS, but check the script first. A `lint` script that already
carries `--fix` and its own glob (`eslint --fix "src/**/*"`) ignores the files
you pass and rewrites the whole tree. Call the linter directly in that case.

Three parts are load-bearing:

- `cd $DIR` plus `--relative`. Without both, paths stay repo-root-relative and a
  containerised linter whose cwd is the sub-project receives `api/api/...`.
- The `[ -z ]` guard. GNU xargs runs its command on empty input, so an empty
  expansion becomes an auto-fix across the entire project.
- `--diff-filter=ACMR`. Drops staged deletions, which the linter cannot open.

`git add` re-stages whole files. If you staged only some hunks, check `git diff`
is empty for those paths first.

If offenses remain after auto-fix, fix them by hand. Never commit with violations.

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
- `vgsa/fix-webhook-retry-timeout`
- `vgsa/add-retry-button-exports`
- `vgsa/refactor-payment-processor`

Rules:
- Prefix: always `vgsa/`
- Suffix: lowercase, hyphen-separated description of the change
- Keep it concise but descriptive enough to understand the PR purpose

## Rules

- **Always run the project's linter before committing**, resolved from
  `~/.claude/shared/project-checks.md`. Never name a runner here.
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

If the user asked only to commit, return the branch URL and stop:

```
https://github.com/<owner>/<repo>/compare/<branch>?expand=1
```

Example output:
```
Pushed to `vgsa/fix-webhook-retry-timeout`

Open PR: https://github.com/<owner>/<repo>/compare/<branch>?expand=1
```

Never run `gh pr create` from this skill. If the user asked for a PR in the same
breath, hand off to the `pull-request` skill after the push. If they only asked
to commit, return the compare URL and stop.
