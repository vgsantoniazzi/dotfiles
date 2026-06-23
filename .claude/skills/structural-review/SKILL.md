---
name: structural-review
description: Diff-scoped STRUCTURAL maintainability audit — file/class sprawl, fat models and service objects, tangled control flow, layering and boundary violations, against-the-grain framework use. A harsh, high-conviction structural lens that complements (does not replace) code-review. Invoke deliberately ("structural review", "/structural-review") when a diff touches module boundaries, large or new files, or a refactor. Read-only: produces findings, never edits.
allowed-tools: Bash(git *), Read, Glob, Grep, Agent
---

# Structural Review

A deliberate, read-only structural-maintainability pass over a diff. Where code-review asks "is this correct and operable" and assessment scores quality holistically, this skill asks one question at a hard bar: **is this change making the codebase structurally worse to maintain?** Surface architectural rot first; skip cosmetic nits entirely when structural issues exist.

This skill is explicitly invoked. It must NEVER auto-fire on the bare word "review" — that is the code-review skill. Run it as a structural lane in parallel with code-review, before git-commit, when a diff touches module boundaries, large or new files, or a refactor.

## Scope

Apply the rubric ONLY to what the diff and the changed files show. Trace cross-file impact when a change touches a module boundary, a shared model, or a public method. Default base branch is `main`.

Gather context first (read-only): `git diff <base>...HEAD`, `git status`, and the full contents of changed files. For large changes, spawn an Explore agent to map callers/dependencies of touched boundaries rather than guessing.

## The Structural Rubric (priority order)

Report findings in THIS order. A lower finding is omitted if a higher one dominates the same code.

### 1. Responsibility sprawl
- A class/file/module that has grown a new, unrelated responsibility. The tell is mixed reasons-to-change: persistence + formatting + dispatch in one object.
- Fat Rails models and fat service objects accreting methods. Fat controllers doing domain work.
- **File size is a SYMPTOM, not a rule.** A file past ~1k lines is a should-fix *only when paired with a concrete symptom* (mixed responsibilities, a churn hotspot, a god object). Do not flag size alone.

### 2. Tangled control flow
- The Nth branch added to a growing switch/case/if-elsif ladder — especially dispatch by type. That is the moment to extract a polymorphic collaborator (a notifier, a strategy), not add branch N+1.
- Deep nesting, long methods doing several things, boolean-parameter flags that fork behavior.

### 3. Boundary & layering violations
- Domain logic leaking into controllers, views, jobs, or migrations.
- A model reaching across an aggregate it shouldn't own; a "job" that is really a service with a `perform` method.
- Skipping the canonical layer the codebase already uses for this concern — the sibling code shows the grain; follow it.

### 4. Against-the-grain framework use
- Re-implementing what Rails/ActiveRecord/the framework already gives you; fighting the ORM; hand-rolling what should be a scope, validation, or association (or hiding control flow inside callbacks where it should be explicit).
- Leaky or premature abstraction: an interface introduced before there is pain, or a wrapper that only forwards.

### 5. Coupling, duplication, and types
- New tight coupling between modules that were independent; a change that forces shotgun edits across many files.
- Duplication that should be unified — but weigh against premature DRY. Two similar blocks are cheaper than the wrong abstraction.
- Implicit/stringly-typed data crossing a seam that deserves an explicit shape.

## Anti-Rewrite Discipline (non-negotiable)

Recommend the **smallest structural change that resolves the issue.** Refactor, don't rewrite (Fowler); be skeptical of rewrites (Spolsky). If a recommendation's payoff is speculative or depends on scale that does not exist yet, mark it **nice-to-have**, not blocking — abstractions before pain are a defect here, not a virtue. Never recommend a rewrite when an extraction will do.

## Output

Display findings VERBATIM. For each, use the evidence-based finding format:

- **Evidence** — `file:line` and the structural smell, quoted.
- **Why it matters** — the concrete maintenance cost (who pays, when, how this rots further).
- **Minimal structural fix** — the smallest change (extract, move, collapse a branch). No rewrites.
- **Test that protects the change** — what proves behavior is preserved across the refactor.

Group as **Must-fix structural / Should-fix structural / Nice-to-have**. Be direct and high-conviction; do not soften. Before presenting, pass the findings through the review-recommendations skill to strip context-free dogma and high-conviction noise — every finding must tie to THIS diff with real maintenance impact, not a best-practices list.

## Boundaries

- **Read-only.** Produce findings; never Edit, Write, commit, or post to a PR. No `gh ...reviews`.
- Fixes the user approves flow back through the normal chain: tdd-bug-fix (if behavior changes) → fix → code-review → operational-review, under the ask-all-questions-first gate. This skill does not implement them.
- A structural lane that runs in parallel with code-review BEFORE git-commit — not a replacement. Correctness, security, and operability remain code-review's and operational-review's job.
- Does not pair with any comment-posting skill. Output stays local.
