---
name: step-back
description: Pause mid-implementation and critically evaluate whether the current changes still solve the original problem. Use when the user says "take a step back", "step back", "are we on track", "are we solving the right problem", "sanity check", or /step-back. Read-only, proposes a course correction, never edits or commits.
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Glob, Grep
---

# Step Back

Stop. Before writing any more code, evaluate whether the current direction actually solves the original problem. This is read-only: you assess and recommend; the user decides and executes.

## Philosophy

It is easy to get tunnel vision mid-implementation, chasing test failures, fixing lint errors, refactoring adjacent code, and lose sight of whether the changes address the original goal. A small early wrong assumption compounds until the solution is detached from the ask. This skill forces a deliberate pause to realign before the cost is sunk into commit → review → PR → push.

## Step 1: Identify the Original Goal

Look back through the conversation:
- What did the user originally ask for?
- What problem were we solving?
- What constraints or requirements were stated upfront?

State the goal in one sentence. If it is unclear, ask every clarifying question you have at once, wait for all the answers, then continue, do not ask one at a time.

## Step 2: Review What's Changed

Run `git diff` (staged and unstaged) and `git status` for untracked files. Summarize in a few bullets: which files were touched, what was added/removed/modified, and what behavior changed.

## Step 3: Assess Alignment to Intent

For each change ask:
- Does this directly contribute to the original goal?
- Is it necessary, or a tangent ("while I'm here", premature abstraction)?
- Are we over-engineering? Would a simpler approach work?
- Are we solving the right problem, or did the first approach reveal the real problem is elsewhere?

**Stay in your lane.** Judge only fidelity-to-intent, whether the work still serves the original ask. Do NOT critique code quality, naming, tests, or operational concerns; that is the code-review, assessment, and operational-review skills. If you notice a quality issue, note "run /code-review" and move on.

## Step 4: Output

### Goal
One sentence restating the original problem.

### Changes So Far
Bulleted summary.

### Assessment
One of:
- **On track**, changes are focused and moving toward the goal. Keep going.
- **Drifting**, some changes are tangential. Name what to drop or defer.
- **Wrong direction**, the approach won't solve the actual problem. Explain why and propose an alternative.

### Recommendation
A concrete, actionable course correction: what to revert, change, or try instead. **Never revert, edit, or commit yourself, propose it; the user executes.** You may recommend invoking other skills (tdd-bug-fix, code-review, pull-request) but do not chain into them.

Be honest. The whole point is to catch mistakes early, not to rubber-stamp the current approach.
