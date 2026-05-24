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

`vgsa/<descriptive-slug>` — lowercase, hyphen-separated, specific enough that the slug tells the reviewer what changed.

Examples:
- `vgsa/fix-eligible-customer-n-plus-one-query`
- `vgsa/add-coupon-validation-campaign`
- `vgsa/refactor-wallet-integration-client`

## PR Description: Principles

A reviewer should grasp the point in under 10 seconds and the full PR in under a minute. Optimize for skimmability.

1. **Lead with the point.** First 1–2 sentences answer "what + why". No throat-clearing, no preamble.
2. **Bullet the lists.** Discrete changes, out-of-scope items, follow-ups, and risks are lists — write them as lists. Don't bury bulletable content in prose.
3. **Prose only for insight.** Use a paragraph when the *why* of an approach isn't visible in the diff: a tricky tradeoff, a rejected alternative, a non-obvious constraint. Otherwise skip it.
4. **One idea per sentence.** Long sentences fused with em-dashes are a smell. Split them.
5. **Cut the obvious.** Don't restate the title. Don't list every modified file. Don't announce "tests pass" unless the result is surprising.

**Length check:** most PRs land at 80–200 words. If you cross 300, ask whether every paragraph is load-bearing.

## PR Description: Structure

Use `.github/pull_request_template.md` if present. Otherwise default to a single `### Description` section shaped like:

```
<1–2 sentence hook: what changes, why>

<optional short paragraph: the non-obvious technical insight, if any>

Changes:
- <discrete change>
- <discrete change>

<Out of scope / Follow-ups / Notes — only the headers you actually need>
- <gotcha, rejected alternative, or scoping note>
```

Before writing, run `gh pr list --state merged --limit 3` and skim 2–3 recent PRs to match team conventions for ticket links, section labels, and tone.

## What NOT to Include

- AI/Claude attribution — never
- A `## Test plan` section — tests are run before the PR, not enumerated in it
- A bullet-point changelog of every modified file
- Generic filler ("This PR adds the feature", "All tests pass")
- Sections the template doesn't have
- "I considered X..." unless X is a real alternative a reviewer might propose

## Examples

### Bug fix — tight prose, one follow-up

```
### Description

When async vendors like Wogi run out of funds (NSF), the payout blocker queue drains slowly: `redemption_clearable?` requires `purchase_completed_at`, which for async vendors is only set when the webhook arrives. That webhook can take 10+ seconds, exceeding the blocker's clearance timeout.

The fix clears the blocker if a `vendor_token` is present on the merchant card. A spec reproducing the bug is included.

Follow-up: extract this check into a shared module so other async vendors get the same behavior.
```

### Feature — hook, insight paragraph, notes bullets

```
### Description

Lets users find all logs related to a payout or gift in Datadog without manually collecting `request_id`s for each version.

`datadog_url` gains a `with_request_id` option that pulls request_ids from PaperTrail versions of the model and its associations, then appends them as OR clauses to the Datadog search query. The ideal version would hit Datadog's API directly, but PaperTrail is sufficient for debugging and adds no new infra.

Notes:
- Capped at 50 versions per model to avoid blowing up queries on long-history records
- Read-only; no schema or API changes
```

### Cleanup — evidence, bullet-heavy

```
### Description

Removes the `api_show_all_funding_sources` config flag. Migration completed September 2025; production query confirms 0 orgs still use the old behavior.

Changes:
- `FundingSourcesController` always calls `all_funding_sources`
- Removed `filtered_funding_sources` and `show_all?` helpers
- Removed `api_show_all_funding_sources?` from `Organization`
- Removed config definition from `organization_config.en.yml`
- Deleted maintenance task and spec used for the migration
- Updated tests to drop config-based scenarios
```

## Workflow

### Pre-PR Checks (MANDATORY)

```bash
# Ruby/Rails
bundle exec rubocop [changed files]
bundle exec rspec [affected spec files]

# JavaScript/TypeScript
npx eslint [changed files]
npx tsc --noEmit
npm run test
```

Fix offenses before the PR. Never create a PR with failing tests or lint violations.

### Artifacts

If the PR template references Asana tickets, Slack threads, or similar, ask the user for the link first. Don't leave the field blank or guess.

### Steps

```bash
git checkout -b vgsa/<descriptive-slug>
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
- **Never offer to merge the PR** — the user merges via GitHub
