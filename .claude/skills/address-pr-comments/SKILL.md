---
name: address-pr-comments
description: Ingest existing review comments on a pull request (human or Cursor), classify each as fix or dismiss, then apply approved fixes through the project's gates. Use when the user says "address PR comments", "handle PR feedback", "fix PR comments", "pr comments", or wants to act on review feedback. NEVER posts anything back to the PR. NEVER creates a PR.
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Skill
---

# Address PR Comments

Work through every review comment on an existing pull request: apply the fixes that improve correctness, security, or readability, and dismiss the rest with clear reasoning. This skill reads inbound comments, it never posts, replies, reacts, approves, or requests changes, and it never creates a PR.

If a PR number or URL is provided, use it. Otherwise detect the PR from the current branch with `gh pr view --json number`. If there is no PR for the branch, stop and tell the user, do not create one.

## Philosophy

Not every comment deserves a code change. Apply fixes that improve correctness, security, readability, or consistency. Dismiss comments that are subjective preferences, over-engineering, or would make the code worse. A short honest dismissal beats a vague one. Every applied fix goes through the same gates as any other code change, no shortcuts because "a reviewer asked for it."

## Step 1: Gather Context

Run in parallel:
- `gh pr view <number> --json title,body,baseRefName,headRefName,files`
- `gh pr diff <number>`
- `gh api repos/{owner}/{repo}/pulls/<number>/comments`, inline review comments
- `gh api repos/{owner}/{repo}/issues/<number>/comments`, general PR comments
- `gh pr view <number> --json reviews`, review-level comments

## Step 2: Catalog Comments

Build a list of every comment: author, file/line (if inline), and what it asks for. Group related comments (a thread about one issue) so they are addressed together, not individually.

## Step 3: Classify Every Comment, Do NOT Edit Yet

For each comment or group, classify as **fix**, **dismiss**, or **ambiguous**.

**Fix**, real bug or edge case, security issue, error handling that matters, genuine readability/consistency problem, or a simple clearly-beneficial request.

**Dismiss**, subjective style with no clear benefit, over-engineering or premature abstraction, misunderstands intent/context, adds complexity without value, or already addressed.

**Ambiguous**, has merit but also drawbacks; needs a user decision.

Print the full classification table. Mark which fixes are **bug fixes** (they will need a failing test first) and which touch **significant** behavior (they will need operational-review).

## Step 4: Ask Everything, Then Build the Plan, Single Gate

Before changing any file: ask ALL ambiguous-comment questions in one batch and wait for the answers. Do not interleave questions with work. Once answered, build a todo list covering every "fix" comment in PR order, and work it one item at a time, updating status as you go.

Nothing is edited before this gate.

## Step 5: Apply Fixes Through the Gates

Work the todo list one item at a time. For each fix:
1. Read the relevant file(s) to understand current state.
2. If the comment is a **bug fix**, use the tdd-bug-fix skill, write the failing test first, watch it fail for the right reason, then fix.
3. Otherwise make the minimal change the comment asks for. Do not refactor surroundings or add unrelated improvements.
4. **Never add a code comment, even if the reviewer explicitly asked for one.** Put the rationale in the PR reply you hand back to the user, or in the commit message, never in the source.

## Step 6: Verify Before Committing

- Run the project's linter and its relevant test suite locally and require green.
  Resolve both from `~/.claude/shared/project-checks.md`. Never invoke a host
  toolchain where the project documents a containerised one.
- Run the code-review skill on the applied diff and display its output VERBATIM.
- Run operational-review for any significant change.

Fix anything these surface before continuing. Never rely on CI to validate.

## Step 7: Commit and Push

- Commit ONLY via the git-commit skill. Do not hand-write the commit or its message, git-commit enforces the message structure, the linter auto-fix, the `vgsa/` convention, and the no-AI-attribution rule.
- After a green commit, push to the existing PR branch. Make the push explicit and confirm with the user first, per their commit workflow.
- Never create a PR here. Never post the dismissals or any reply to GitHub.

## Step 8: Report Dismissals (Terminal Only)

Print dismissed comments locally so the user can reply themselves:
```
## Dismissed Comments
**[author] on file.rb:42**, "suggestion text..."
→ Dismissed: <one-sentence reason>
```

## Step 9: Summary
```
## Summary
- X comments addressed (fixes applied + committed)
- Y comments dismissed (reasons above, for you to post)
- Z comments awaiting your decision (if any blocked the gate)
```

## Hard Rules
- NEVER post comments, replies, reactions, approvals, or change-requests to the PR. Output is local; the user replies.
- NEVER create a PR. If the branch has none, stop and say so.
- NEVER hand-roll a commit, always the git-commit skill.
- NEVER skip lint + tests locally before pushing.
- NEVER add code comments, even on request.
- Bug-fix comments go through tdd-bug-fix. No exceptions.
- Ask all ambiguous-comment questions in one batch before editing anything.
