---
name: pull-request
description: Create pull requests with descriptions optimized for skimmability. Branch naming, bullet-leaning PR bodies, length discipline.
---

# Pull Request Workflow

Create branches and PRs with descriptions that respect the reviewer's time.

## When to Use

Activate when the user:
- Asks to create a PR/pull request
- Says "open PR", "create PR", "submit for review"
- Wants to push and create a PR in one flow

## Branch Naming

`vgsa/<descriptive-slug>`, lowercase, hyphen-separated, specific enough that the slug tells the reviewer what changed.

Examples:
- `vgsa/fix-eligible-customer-n-plus-one-query`
- `vgsa/add-coupon-validation-campaign`
- `vgsa/refactor-wallet-integration-client`

## PR Description: Principles

A reviewer should grasp the point in under 10 seconds and the full PR in under a minute. Optimize for skimmability.

1. **Lead with the point.** First 1 to 2 sentences answer "what + why". No throat-clearing, no preamble.
2. **Bullet the lists.** Discrete changes, out-of-scope items, follow-ups, and risks are lists, write them as lists. Don't bury bulletable content in prose.
3. **Prose only for insight.** Use a paragraph when the *why* of an approach isn't visible in the diff: a tricky tradeoff, a rejected alternative, a non-obvious constraint. Otherwise skip it.
4. **One idea per sentence.** Long sentences fused with em-dashes are a smell. Split them.
5. **Cut the obvious.** Don't restate the title. Don't list every modified file. Don't announce "tests pass" unless the result is surprising.

**Length check:** most PRs land at 80 to 200 words. Treat 300 as a hard cap. If you are near it, cut.

## PR Description: Structure

Use `.github/pull_request_template.md` if present. Otherwise default to a single `### Description` section shaped like:

```
<1 to 2 sentence hook: what changes, why>

<optional short paragraph: the non-obvious technical insight, if any>

Changes:
- <discrete change>
- <discrete change>

<Out of scope / Follow-ups / Notes, only the headers you actually need>
- <gotcha, rejected alternative, or scoping note>
```

Before writing, run `gh pr list --state merged --limit 2 --json number,title,body --jq '.[] | "=== #\(.number) \(.title) ===\n\(.body)\n"'` and read them to match team conventions for ticket links, section labels, and tone.

## What NOT to Include

- AI/Claude attribution, never
- A `## Test plan` section, tests are run before the PR, not enumerated in it
- A bullet-point changelog of every modified file
- Generic filler ("This PR adds the feature", "All tests pass")
- Sections the template doesn't have
- "I considered X..." unless X is a real alternative a reviewer might propose

## Examples

Match the repo's own recent merged PRs rather than a canned example. Read two
with the command above and follow their section labels, ticket-link style, and
tone.

## Workflow

### Pre-PR Checks (MANDATORY)

Run **what CI runs**. Resolve it from `~/.claude/shared/project-checks.md`,
reading the repo's CI config first. No `$(...)` here on purpose: a PR gate must
match CI exactly, and matching CI removes the empty-expansion failure mode
rather than guarding it.

Run this **after** the commit exists, otherwise every count is zero and the
gate disarms itself. Sub-project names come from the repo's own layout docs.

```bash
base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)
for d in <sub-projects>; do
  echo "$d: $(git diff --name-only "$base"...HEAD -- ":(top)$d" | wc -l) changed"
done
```

Then run that sub-project's documented lint and test commands, from its own
directory, through its own runner. Read the repo's CI workflow for the exact
strings, including any database or fixture preparation step the docs omit.

Never run a host `bundle exec` where a containerised runner exists. It does not
error, it passes against a different toolchain and tells you nothing.

Fix offenses before the PR. Never open a PR on failing checks.

### Artifacts

If the PR template references ticket links, Slack threads, or similar, ask the user for the link first. Don't leave the field blank or guess.

### Steps

```bash
git fetch origin
base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)
git rev-list --count "$base"..HEAD   # 0 means safe to branch from base
git switch -c vgsa/<descriptive-slug> "$base"
# (commit via git-commit skill)
git push -u origin vgsa/<descriptive-slug>
gh pr create --title "..." --body "$(cat <<'EOF'
...
EOF
)"
```

## Rules

- Always use `vgsa/` branch prefix
- Never include AI attribution in title or body
- Confirm with the user before running `gh pr create`
- Return the PR URL when done
- **Never offer to merge the PR**, the user merges via GitHub
