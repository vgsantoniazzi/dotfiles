---
name: pull-request
description: Create pull requests with clear, readable descriptions. Branch naming conventions and prose-first PR bodies.
---

# Pull Request Workflow

Create branches and pull requests with well-written, readable descriptions.

## When to Use

Activate when the user:
- Asks to create a PR/pull request
- Says "open PR", "create PR", "submit for review"
- Wants to push and create a PR in one flow

## Branch Naming Convention

Always create branches with the format: `vgsa/<descriptive-slug>`

Examples:
- `vgsa/fix-eligible-customer-n-plus-one-query`
- `vgsa/add-coupon-validation-campaign`
- `vgsa/refactor-wallet-integration-client`

Rules:
- Prefix: always `vgsa/`
- Suffix: lowercase, hyphen-separated description of the change
- Be specific enough that the branch name tells a story

## PR Description Format

### Step 1: Follow the Project Template

Before writing the PR body, check for `.github/pull_request_template.md` in the repo. If it exists, **use its exact structure** — fill in each section from the template. Do not invent your own sections or skip template sections.

### Step 2: Match Recent PR Conventions

Read 2-3 recent merged PRs (`gh pr list --state merged --limit 3` then `gh pr view <number>`) to match the team's current conventions for:
- How they format the Asana/ticket link (raw URL vs markdown link)
- Level of detail in descriptions
- Whether they use `### How to Review` or `#### Why / What` subsections
- Tone and formality

### Step 3: Write the Description

Write like a distinguished engineer talking to a colleague: narrative-first, precise, and honest. The description should read as flowing prose that tells a story — why we're here, what we did, and what to watch out for. Use bullet points when listing discrete items (files, steps, vendors), but the primary voice is prose.

**Title**: Short, imperative summary (same style as commit summary)

**Body** (within the template structure):

1. **Lead with the story** — Start with the problem as a narrative. What happened? What's the pain? Link to Slack threads, Sentry errors, or incidents that triggered this. The reader should immediately understand *why* this PR exists and feel the urgency (or lack thereof).

2. **Explain the approach** — Describe what you did and *why this way* over alternatives. Be honest about trade-offs: "An ideal solution would X, but Y is sufficient because Z." Include the key technical insight that makes the fix non-obvious. Use bullet points for listing discrete changes when there are several.

3. **Be transparent about scope and risks** — What does this NOT fix? What follow-up is planned? What could go wrong? Mention if you considered and rejected alternatives. Invite discussion: "If you feel strongly about X, let's iterate."

**Tone**: Conversational but precise. It's okay to say "I wondered about...", "this is fine IMO because...", or "if you disagree, feel free to reject." The PR is a conversation, not a formal report.

### What NOT to Include

- **Never mention AI/Claude** — The PR stands on its own merit
- No bullet-point changelogs listing every modified file
- No excessive headers beyond what the template provides
- No obvious statements like "This PR adds the feature"
- Do not add sections not present in the template (e.g., don't add `## Test plan` if the template doesn't have it)

## Examples

### Bug fix — narrative, evidence, follow-up

```
### Asana Ticket and/or Slack Thread

Asana ticket: https://app.asana.com/...

### Description

When async vendors like Wogi run out of funds (NSF), the payout blocker queue
drains slowly. This happens because redemption_clearable? requires
purchase_completed_at to be set, but for async vendors this is only set when the
webhook arrives (which in some cases can take 10+ seconds, exceeding the blocker
clearance timeout).

Add a spec that reproduced the bug, and adjust the code to clear the blocker if
a vendor_token is present on the merchant card. A follow up PR will make this
test shared outside of merchant cards and add specs to relevant vendors.
```

### Improvement — story, trade-offs, honest scoping

```
### Asana Ticket and/or Slack Thread

Slack thread: https://tremendous-rewards.slack.com/archives/...

### Description

When investigating issues in Datadog, finding all logs related to a payout or
gift requires manually searching for each request_id that touched the record.
This is tedious because a single payout may have dozens of versions from
different requests over its lifecycle.

This change adds a with_request_id option to datadog_url that extracts
request_id values from PaperTrail versions of the model and its associations.
It appends these as OR clauses to the Datadog search query, making it easy to
find all logs from every request that modified the record. The feature limits
versions loaded to 50 per model to avoid overwhelming queries on records with
extensive history.

An ideal solution would hit Datadog's API to fetch all request_id's, but pulling
from PaperTrail versions is sufficient for debugging purposes and requires no
schema changes.
```

### Cleanup — evidence-based removal

```
### Asana Ticket and/or Slack Thread

Asana ticket: https://app.asana.com/...

### Description

The Funding Sources API had a config flag (api_show_all_funding_sources) that
controlled whether to show all funding sources or only active, API-enabled ones.
The migration was completed in September 2025, and all customers now use the new
behavior (confirmed by production query showing 0 orgs with the old config).

This commit removes all conditional logic and config related to
api_show_all_funding_sources. The API now always returns all funding sources.
The changes include:

- Simplified FundingSourcesController to always call all_funding_sources
- Removed filtered_funding_sources method and show_all? helper
- Removed api_show_all_funding_sources? from Organization model
- Removed config definition from organization_config.en.yml
- Deleted maintenance task files used for the migration
- Updated tests to remove config-based scenarios
```

## Workflow

### Step 0: Ask for Artifacts

Before creating the PR, check if the template requires links or references (Asana tickets, Slack threads, Notion docs, etc.). If the user hasn't provided them and the template has fields for them, **ask the user** — don't leave them blank or guess.

### Steps 1-4: Create the PR

```bash
# 1. Create and switch to new branch
git checkout -b vgsa/<descriptive-slug>

# 2. Make commits (use git-commit skill)

# 3. Push with upstream tracking
git push -u origin vgsa/<descriptive-slug>

# 4. Create PR
gh pr create --title "PR title" --body "$(cat <<'EOF'
Description paragraph here.

Additional context if needed.
EOF
)"
```

## Rules

- Always use `vgsa/` branch prefix
- Never include AI attribution in title or body
- Prefer prose over bullet points
- Write descriptions that are pleasant to read
- Ask user to confirm before creating the PR
- Return the PR URL when complete

## After Creating

Display the PR URL:
```
Created PR #123: https://github.com/org/repo/pull/123
```

**NEVER ask to merge the PR** - the user will always merge via GitHub directly.
