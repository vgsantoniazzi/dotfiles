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

Write PR descriptions as **readable prose**. The goal is a description that's pleasant to read, not a changelog dump.

### Structure

**Title**: Short, imperative summary (same style as commit summary)

**Body**:

1. **Opening paragraph** - What does this PR do and why? Write it as if explaining to a colleague who just sat down next to you. Include the problem context and the solution approach in flowing prose.

2. **Additional paragraphs** (if needed) - Technical details, trade-offs, or decisions that reviewers should understand. Continue using prose.

3. **Bullet points** (only if truly necessary) - Use sparingly for:
   - Sequential flows or processes (e.g., OAuth handshake steps, data pipeline stages)
   - Listing affected files/components when the scope is unusually broad
   - Breaking changes or migration notes
   - Required environment variables or setup steps

   If the information flows naturally as prose, prefer prose.

### What NOT to Include

- **Never mention AI/Claude** - The PR stands on its own merit
- No "Changes" or "Testing" sections
- No bullet-point changelogs listing modified files
- No excessive headers or formatting
- No obvious statements like "This PR adds the feature"

## Examples

### Good PR Description (prose-focused)

```
Fix N+1 query in eligible customers lookup

The bulk contact job was loading customers eligible for re-engagement messages, but each customer triggered a separate query to check their last interaction date. On organizations with 10k+ customers, this caused the job to timeout.

This change eager-loads the interaction timestamps in the initial query and filters in Ruby. The trade-off is slightly higher memory usage, but the query time drops from 45s to under 2s for our largest organization.
```

### Good PR Description (with necessary bullets)

```
Add Google Wallet support for loyalty cards

Customers can now add their loyalty card to Google Wallet directly from the rewards page. When their points balance changes, the card updates automatically via the Google Wallet API.

The implementation follows Google's JWT-based flow where we sign the loyalty object and redirect the user to Google's "Add to Wallet" endpoint. Push updates happen through a background job triggered by the existing points cache refresh.

**Setup required:**
- Add GOOGLE_WALLET_ISSUER_ID to environment
- Configure service account in Google Cloud Console
```

## Workflow

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
