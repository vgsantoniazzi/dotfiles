---
name: draft-review-comments
description: Turn EXISTING review findings into concise, anchored inline GitHub PR comments and post them as one batched review after explicit approval. For reviewing OTHERS' pull requests — never your own author flow. Use when the user asks to turn a review into PR comments, draft inline comments from findings, post review comments, or invokes /draft-review-comments. Manual invocation only; never auto-triggers after code-review. Never posts without approval.
allowed-tools: Read, Grep, Glob, Write, Bash(gh pr view *), Bash(gh pr diff *), Bash(gh api *)
---

# Draft Review Comments

Turn review findings that already exist in the conversation into inline PR comments on a teammate's pull request, posted as one batched review after you approve the drafts. This is the publishing tail of a review — it does NOT review code itself, and it never runs on the user's own author flow (git-commit and pull-request own that).

If there are no findings in context, stop and tell the user to run a review first (code-review, assessment, or structural-review), then re-invoke. Do not run the review yourself.

## Step 1: Locate Findings

Use the most recent review findings in context, a findings file the user names, or pasted findings. Each finding should identify the concern, the file/region, and the suggested fix.

## Step 2: Resolve the PR and Ask Everything Up Front

Resolve the target PR:
```
gh pr view <number-or-url> --json number,url,headRefOid,state,isDraft,author
gh pr diff <number>
```
Keep `headRefOid` — it becomes `commit_id` when posting. If there is no PR, stop.

Then ask ALL open questions in one batch and wait for answers before drafting:
- Which PR, if ambiguous?
- Which review event to post: COMMENT (default), REQUEST_CHANGES, or APPROVE?
- Which subset of findings to include, if not all?

**Default the event to COMMENT.** Only use APPROVE or REQUEST_CHANGES if the user explicitly names that verdict — never volunteer a gating verdict. If the PR is the user's own, GitHub blocks APPROVE/REQUEST_CHANGES; force COMMENT and say so.

## Step 3: Map Anchors

For each finding pick the tightest anchor inside a diff hunk:
- Single line: `path`, `line`, `side: RIGHT` (added/changed) or `LEFT` (deleted).
- Range: `path`, `start_line`, `start_side`, `line`, `side`.

If the target line is not in the diff, anchor to the nearest changed line in the same hunk or move the finding to the review summary — and tell the user you relocated it.

## Step 4: Draft Short Comments — Preserve Substance

One point per comment, 20–35 words, hard cap 55. Lead with curiosity; assume the author had a reason. Ask why the code is shaped this way and name the concrete concern ("is there a reason…", "could we…", "how would you feel about…"). For a blocker, name the impact directly.

**The posted comment is a derived artifact, never a replacement for the finding.** You may reword for tone and politeness, but you may NOT drop the finding's technical substance or its severity. Don't bury blocker impact in politeness; don't make nits sound mandatory.

## Step 5: Show Drafts Beside Their Source

Present every draft as a numbered list. For EACH, show the original finding text next to the drafted comment and its anchor, so the user can verify nothing was lost:
```
1. src/user_service.rb:312  (anchor: RIGHT)
   FINDING:  <original finding text, verbatim>
   COMMENT:  <drafted comment>
```
Note any finding moved to the summary. Wait for the user to edit, drop, merge, or approve. Do not post yet.

## Step 6: Post One Batched Review

After explicit approval, create one pending review with all inline comments and submit it once with the chosen event. Use `commit_id` from `headRefOid`. Write the payload to a temp file with the Write tool so quotes in comment bodies are handled cleanly. Report the review URL and how many comments posted.

## Hard Rules
- Never post without explicit user approval after Step 5.
- Post one batched review, once.
- Default to COMMENT; never volunteer APPROVE or REQUEST_CHANGES.
- Only for reviewing others' PRs — never the user's own author flow.
- Manual invocation only; never auto-trigger after a review skill.
- Preserve every finding's substance and severity; rewording is for tone only.
