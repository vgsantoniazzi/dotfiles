---
name: qa
description: Exhaustive full-stack QA via parallel specialist agents. Generates a target-specific edge-case matrix, verifies backend data + frontend behavior (Playwright), reports breakages with evidence. Stage 1 is read-only on app code; Stage 2 applies user-approved fixes with a severity-gated skill chain.
---

# QA Skill

Spawn parallel specialist agents to break a feature end-to-end before users do. Target-specific edge cases. Real DB. Real browser. Evidence, not opinions.

## Core Principle

> Every feature fails at its edges. QA that only runs the happy path is theater. This skill thinks about *this* target's failure modes first, then uses a coverage checklist to make sure nothing obvious was skipped.

## When to Use

- Before merging a full-stack feature (backend + frontend)
- After a refactor that touches both sides of an API contract
- To reproduce a reported bug with a dense edge-case sweep
- Pre-release gate on anything that moves money, sends notifications, or touches auth

## When NOT to Use

**This skill is expensive.** Three parallel agents, real DB seeding, a real browser, 20-60 cases. It is the wrong tool for:

- Single-file bug fixes → `tdd-bug-fix`
- Pure code quality review → `assessment` or `code-review`
- Changes under ~50 lines with obvious blast radius → just read the diff
- Load / performance / visual regression / accessibility → out of scope

If the change is small, do not reach for this. You'll regret the time and context cost.

## Two Stages — Hard Boundary

| Stage | Phases | Mode | Claude may... |
|-------|--------|------|---------------|
| **1. QA Run** | 0-4 | Read-only on app code | Bring up env, seed test data, exercise API/UI, report |
| **STOP** | — | — | **Present findings. Ask user. Wait.** |
| **2. Fix** | 5 | Write | Apply approved fixes with a severity-gated skill chain |

**Claude MUST NOT modify app code until the user has decided on each finding.** Seeding test data via factories during Stage 1 is allowed; editing controllers, models, components, or migrations is not.

## Context Protection

Phase 2 spawns three specialists **in a single message, in parallel**. Agents return compact result tables (case id, status, evidence path), not raw logs. Full artifacts stay under `tmp/qa/<run-id>/` so the main thread's context stays clean for Stage 2.

---

## Invocation

Free-form prose:

```
/qa the new bulk card issuance flow for org admins
/qa recipient withdrawal via ACH with saved bank accounts
```

If the target is ambiguous (which routes? which UI entry?), the main thread asks one round via `AskUserQuestion` before Phase 0. Wrong target = wasted run.

---

## Stage 1: QA Run

### Phase 0 — Environment bring-up (main thread)

**Goal:** Make the environment healthy. Express intent, not prescribed commands — read the project's `Justfile` / `Makefile` / `package.json` / `compose.yml` first and pick the right tool.

Resolve each concern in order. Skip steps already healthy.

1. **Containers running** (if the project uses them)
2. **Backend deps installed** (bundle / pip / go mod / etc.)
3. **Frontend deps installed** (npm / yarn / pnpm)
4. **DB exists, migrations applied** — if pending migrations, invoke `migration-safety` first
5. **Playwright browsers installed** (Chromium only for MVP)
6. **Backend boots** (smoke: run a trivial runner command)
7. **Frontend dev server responds** — if not up, start in background, record PID for teardown
8. **Base URL guard** — resolved base URL MUST be `localhost` or `127.0.0.1`. If not, abort. No staging, no prod, ever.
9. **Baseline regression** — run the existing test suite scoped to the target area. If it's already red, record that as context for Phase 2 (don't generate new cases on top of a broken baseline).
10. **Smoke GET** the target backend endpoint and frontend route. Non-2xx here is a real finding — record and continue.

**Bring-up rules:**

- **Resolve what you can.** Missing deps, pending migrations, stale browsers — fix them. You have the terminal.
- **Ask only when a human decision is needed:** missing secrets, destructive ops, unfamiliar failures, or fixes that would touch committed files (e.g. `Gemfile.lock` bumps).
- **Never destructive by default.** `db:reset`, `db:drop`, `rm -rf node_modules`, force reinstalls — require explicit user approval.
- **Timebox.** ~5 minutes of real work. If still stuck, stop and report the exact failing command.

---

### Phase 1 — Target mapping + scope gate (main thread)

1. **Map the surface:** backend routes, controllers, services, jobs, models; frontend routes, top-level components, API client calls.
2. **Verify it exists.** If the routes/files/components named in the prose aren't found, stop and ask the user to clarify. Do not run Phase 2 on a phantom target.
3. **Scope gate.** If the surface exceeds **~8 backend routes OR ~6 frontend components**, stop and ask the user to narrow. Big sweeps burn context and produce shallow results.
4. **Mine user knowledge.** One question before spawning: *"Anything you already suspect is broken or haven't been able to test yourself?"* 30 seconds of user context saves 10 minutes of agent guessing. Fold the answer into the Phase 2 briefing.
5. **Produce a target summary** (~20 lines) shared with all Phase 2 agents: surface, auth model, data dependencies, relevant CLAUDE.md conventions, baseline regression status, user's suspicions.

---

### Phase 2 — Parallel specialists

Spawn all three agents in **one message**. They run in parallel and return compact results.

#### Agent A — Edge-Case Generator

```
Agent subagent_type=general-purpose
Prompt: "Generate a target-specific edge-case matrix.

TARGET SUMMARY:
[Phase 1 output, including user suspicions and baseline status]

STEP 1 — Think about THIS target's failure modes first.
What could go wrong for a real user of THIS feature? What assumptions does
this code make that could break? What's the blast radius if each assumption
is wrong? Write 5-10 concrete failure hypotheses BEFORE touching the
dimensions below.

STEP 2 — Use these dimensions as a coverage check on your hypotheses.
For each dimension, verify your matrix covers it. If a dimension is
genuinely N/A for this target, say so with a one-line reason. Do not
pad with cases just to hit numbers.

  1. Empty / boundary sizes (null, empty, 0, 1, max, max+1, 10k rows, 1MB strings)
  2. Malformed / unexpected types (wrong type, unicode, emoji, negatives, DST, far-future dates)
  3. Concurrency / duplicates / idempotency (double-submit, retry, race, dup idempotency key)
  4. Auth / permissions / network (wrong org, expired token, timeout, partial response, 500 upstream)

STEP 3 — Emit cases as executable rows. Every case MUST include a
concrete `seeding_command` that B and C can run mechanically — no prose,
no 'create a user with...'. Example:
  seeding_command: \"just rails runner 'FactoryBot.create(:recipient, name: \\\"José García 🎉\\\", organization_id: 42)'\"

Row format:
{
  id: 'EC-001',
  dimension: 'malformed_types',
  surface: 'backend' | 'frontend' | 'both',
  hypothesis: '<the failure this probes>',
  seeding_command: '<exact shell command or N/A>',
  action: '<exact API call or UI interaction>',
  expected: '<what should happen>'
}

Return 15-50 cases. Count is a function of target complexity — do not
inflate. Every case must probe a real hypothesis, not a theoretical one."
```

#### Agent B — Backend Data Verifier

```
Agent subagent_type=general-purpose
Prompt: "Verify backend behavior for the target against the edge-case matrix.

TARGET SUMMARY:
[Phase 1 output]

EDGE CASE MATRIX:
[Agent A output, filtered to surface in ('backend', 'both')]

RUN ID: [run-id]

For each case:
1. Run `seeding_command` exactly as provided.
2. Execute `action` against the real endpoint (curl or runner HTTP).
3. Assert: HTTP status, response shape, DB state (query via runner),
   no unintended side effects.
4. Save raw evidence to tmp/qa/<run-id>/backend/EC-<id>.log
5. Record: PASS | FAIL | SKIP (with reason)

Rules:
- Never mock. Real DB, real endpoints.
- Never edit app code. Seeding only.
- On seeding failure: SKIP with reason 'seeding_failed: <error>'. Not PASS.
- On FAIL: capture full response body and relevant DB rows to the log file.

Return ONLY a compact table + summary — never full logs:
| case_id | status | expected | actual_short | evidence_path |
Summary: 'ran N cases: X PASS, Y FAIL, Z SKIP'"
```

#### Agent C — Frontend Playwright Runner

```
Agent subagent_type=general-purpose
Prompt: "Exercise the frontend against the edge-case matrix.

TARGET SUMMARY:
[Phase 1 output]

EDGE CASE MATRIX:
[Agent A output, filtered to surface in ('frontend', 'both')]

RUN ID: [run-id]

For each case:
1. Run `seeding_command` if present.
2. Write an ephemeral Playwright spec to tmp/qa/<run-id>/frontend/EC-<id>.spec.ts
   — Chromium only, headless, trace + screenshot on failure.
   — Assert base URL is localhost/127.0.0.1 inside the spec.
3. Run: `npx playwright test tmp/qa/<run-id>/frontend/EC-<id>.spec.ts`
4. FLAKINESS RULE: on FAIL, re-run the spec ONCE. Only record FAIL if the
   second run also fails. If the second run passes, record as FLAKY with
   both outputs saved.
5. Keep all artifacts under tmp/qa/<run-id>/frontend/ on FAIL or FLAKY.
6. Record: PASS | FAIL | FLAKY | SKIP

Rules:
- Never edit app code.
- Specs live under tmp/qa/<run-id>/ only — never under spec/ or committed paths.

Return ONLY a compact table + summary:
| case_id | status | expected | actual_short | artifact_path |
Summary: 'ran N cases: X PASS, Y FAIL, Z FLAKY, W SKIP'"
```

---

### Phase 3 — Synthesize (main thread)

Merge the three result sets. Read evidence files only for FAIL and FLAKY cases. Build findings.

Every failing case becomes a finding with:

1. **Evidence** — case id, hypothesis, expected vs actual, artifact path
2. **Impact** — what breaks for real users / what data ends up wrong
3. **Root cause hypothesis** *(optional)* — file:line if identifiable. If unknown, say so — the finding becomes an investigation task in Stage 2.
4. **Test that would catch this** — concrete RSpec or Playwright skeleton. For Playwright cases, note whether the ephemeral spec is worth promoting.

Group by severity:
- **Must-fix** — data loss, auth bypass, money wrong, crash on input a real user could produce
- **Should-fix** — wrong error message, bad UX on edge, silently-swallowed errors
- **Nice-to-have** — polish, defensive guards, missing log context

FLAKY cases are reported separately — not blocking, but surfaced.

---

### Phase 4 — Stop gate

Present the report:

```markdown
## QA Summary

**Target:** [feature]
**Run ID:** [run-id]
**Environment:** localhost ([base URL])
**Bring-up:** [what was resolved, or "clean"]
**Baseline regression:** [green / red with N failing tests]

### Results

| Agent | Cases | PASS | FAIL | FLAKY | SKIP |
|-------|-------|------|------|-------|------|
| Backend | N | N | N | — | N |
| Frontend | N | N | N | N | N |

### Coverage by dimension

| Dimension | Cases | Pass rate | N/A reason |
|-----------|-------|-----------|------------|
| Empty / boundary | N | N% | — |
| ... | | | |

### Findings

[F1, F2, F3... with evidence, impact, root cause (optional), test]

### Action Summary

| ID | Severity | Finding |
|----|----------|---------|
```

Then:

> Ready to work findings one-by-one? I'll present each with evidence and proposed fix. You decide fix / skip / custom. Approved fixes chain into other skills based on severity.

**Wait for confirmation before F1.** Present one at a time. Never batch. Never edit code until every finding has a decision.

---

## Stage 2: Fix (Phase 5)

**Precondition:** every finding has a decision.

1. **`TaskCreate`** one task per approved finding.

2. **Work in finding-id order.** For each approved fix, run the **severity-gated chain**:

   | Severity | Chain |
   |----------|-------|
   | Must-fix | `tdd-bug-fix` → apply fix → re-run the failing case → `code-review` → `operational-review` if the change touches money/jobs/auth/data integrity |
   | Should-fix | `tdd-bug-fix` → apply fix → re-run the failing case → `code-review` |
   | Nice-to-have | apply fix → `code-review` at end of run (batched with other nice-to-haves) |

3. **Re-run verification.** After each fix, re-run the specific failing case (backend curl or the ephemeral Playwright spec from `tmp/qa/<run-id>/`) to prove it's green. If still failing, stop and tell the user — do not mark the task done.

4. **Offer to promote valuable specs.** When a Playwright case caught a real bug, ask: *"promote EC-017's spec to `spec/features/<area>/` as a permanent regression test?"* Do not auto-commit.

5. **Teardown.** Remove `tmp/qa/<run-id>/` only if all approved findings are resolved AND the user hasn't asked to keep artifacts. Stop any background dev server started in Phase 0.

6. **Final summary.** Short block: what was fixed, what was skipped, promoted specs, follow-ups.

**Never** implement anything marked skip. **Never** expand scope beyond approved findings.

---

## Hard Constraints

- Stage 1 is read-only on **application code**. Test-data seeding via factories is fine; editing controllers, models, components, migrations, or committed specs is not.
- **Local dev only.** Base URL MUST resolve to `localhost` or `127.0.0.1`.
- Every finding carries evidence + impact + test. Root cause is optional — investigation task if unknown.
- Phase 2 agents return compact tables. Raw logs live under `tmp/qa/<run-id>/`.
- Never mock the DB or the API under test.
- Never commit `tmp/qa/` artifacts.
- Never batch findings. One at a time. Wait for the user.
- Never skip the Stage 1 → Stage 2 gate.
- Flaky Playwright runs get one retry before being recorded as FAIL.

## Anti-patterns

- Generating cases from the 4-dimension checklist without thinking about this target's specific failure modes first
- Inflating case counts to hit a minimum
- Generator producing prose `seeding_hint` instead of executable `seeding_command`
- Treating a seeding failure as a PASS
- Running `/qa` on a 20-line change
- Editing app code during Phase 2 to "make the test pass"
- Recording a single Playwright flake as FAIL without the retry
- Committing `tmp/qa/` artifacts or auto-promoting specs without asking
- Running the full Stage 2 chain on a nice-to-have
- Hand-waving root causes (if unknown, say unknown)

## Example Finding

```markdown
### F1 — Must-fix: Bulk card issuance silently drops unicode-named recipients

**Evidence:**
Case EC-017 (dimension: malformed_types, surface: both)
Hypothesis: ASCII-only name filter drops international recipients silently
Seeding: `just rails runner 'FactoryBot.create_list(:recipient, 3, organization: Organization.find(42)) { |r, i| r.update(name: ["Alice", "José García 🎉", "Bob"][i]) }'`
Action: POST /v1/bulk_cards with those 3 recipient_ids
Expected: 201, 3 cards created
Actual: 201, 2 cards created — José's row is dropped, no error, no log
Artifact: `tmp/qa/20260414-1a2b/backend/EC-017.log`

**Impact:**
Customers with international recipients lose cards silently. Sending org is
debited for N cards, only N-1 are issued. Silent data loss on a paid flow.

**Root cause hypothesis:**
`app/services/bulk_card_issuer.rb:47` — `recipient.name.ascii_only?` filter
drops non-ASCII rows before the creation loop.

**Test that would catch this:**
```ruby
it "issues cards for recipients with unicode names" do
  recipients = create_list(:recipient, 2, organization:)
  recipients.last.update!(name: "José García 🎉")
  expect { described_class.call(recipients) }.to change(Card, :count).by(2)
end
```

fix, skip, or your own instructions?
```

## Communication Style

- Short sentences. No filler.
- Numbers where they matter (cases run, pass rate, file:line).
- If the feature is solid, say so with case counts as proof.
- If it's broken, say so with evidence.
- No softening. No hedging. No over-praise.
