---
name: assessment
context: fork
agent: general-purpose
background: false
description: Comprehensive, evidence-based code assessment. Evaluates correctness, design, reliability, and testability with weighted scores. Use when the user says assess, assessment, or how good is this. Runs the tests and linter, spawns agents, and refutes every finding before reporting.
---

# Assessment Skill

Comprehensive, evidence-based code assessment. Your job is to evaluate source code, not praise it.

## Core Principle

> Evidence beats opinion. Precision beats coverage. Fewer, deeper insights are better than generic checklists.

If something is unclear, say so. If code is good, say why with evidence. No fluff.

## Two Stages, Hard Boundary

This skill has two stages with a **mandatory stop** between them:

| Stage | Phases | Mode | Claude may... |
|-------|--------|------|---------------|
| **1. Assessment** | 1-5 | Read-only on the repo | Read, analyze, score, refute, report |
| **STOP** | - | - | **Present findings. Ask user. Wait.** |
| **2. Action** | 6 | Write | Create tasks, implement fixes the user approved |

**Claude MUST NOT write or modify any source code until the user has responded with their action plan.**
The assessment is a report. The user decides what to do with it. No exceptions.

## Execution Model

**This skill runs forked.** `context: fork` means the invocation itself spawns
the subagent and this body becomes its prompt, so none of it enters the caller's
conversation. Do not spawn another Stage 1 agent; you already are one.

You have no conversation history. Everything you need is the target, the scope,
and this file. If the caller's intent is ambiguous, say so in the report rather
than guessing, because you cannot ask.

Run Phases 1 to 6, spawning agents for Phase 4 and Phase 5 as those phases
describe. Return the formatted report and stop.

**End the report with the Stage 2 handoff**, because the thread that receives it
never read this file and will not know the protocol otherwise:

> Stage 2, for the main thread: present these findings one at a time, in ID
> order. For each, show the header, evidence, impact, verdict, what refutation
> tried, and the proposed fix, then ask "fix, skip, or your own instructions?"
> and wait. Do not batch. Do not implement anything marked skip.

#### If you cannot spawn agents

**This is not optional and it is not a degraded mode.** You are in it if you are
the Stage 1 agent yourself, if the caller forbade spawning, or if a spawn fails
and does not recover.

Run Phases 1 to 6 yourself, in order, with no phase skipped. The passes in
Phase 5 still all run: you play each one in turn and you do not let what you
found in one colour what you conclude in the next. That is harder alone than it
is with fresh agents, so hold the line deliberately.

Return the formatted report and stop. Stage 2 is the main thread's job, because
it needs a user to answer and you do not have one.

Say so in the report, in the Refutation section: **"Phases 4 and 5 ran
single-threaded."** A reader has to know that the independence the method
depends on was simulated rather than enforced.

## Files

`SKILL.md` is the flow and the decision logic. Load a reference when you reach
the step that needs it, not before.

| File | Contains | Read at |
|---|---|---|
| `references/phases.md` | Phases 1 to 4 in full, with the agent prompts | start of Stage 1 |
| `references/refutation.md` | The three refuter prompts | Phase 5 |
| `references/output.md` | Finding contract, required sections, strict output format | Phase 6 |
| `references/quality-bar.md` | The two checklists | before the stop gate, and before Stage 2 |
| `references/examples.md` | Worked findings, good and bad | when a finding's shape is unclear |

## When to Use

- Before merging significant code
- When inheriting unfamiliar code
- Periodic codebase health checks
- Evaluating code quality objectively
- When you need a thorough, structured assessment

## Primary Goals (Priority Order)

1. **Correctness & edge cases**, Does the code behave correctly in real-world conditions?
2. **Test coverage**, Are the important paths tested? Are tests meaningful, not just padding?
3. **Maintainability & clarity**, Can another engineer safely modify this in 6 months?
4. **Reliability & failure modes**, Only concrete failure scenarios (data loss, silent corruption), NOT generic "add logging"
5. **Security & data safety**, Only if applicable and visible in the code
6. **Performance**, Only if a concrete issue is observable

Do NOT optimize for style unless it impacts the goals above. Do NOT report generic observability gaps as findings.

---

## Stage 1: Assessment (Phases 1-6), READ ONLY ON THE REPOSITORY

**CRITICAL:** Do NOT skip phases. Do NOT start evaluating code until you understand the system it lives in.
**CRITICAL:** Do NOT fix, edit, or implement anything in the repository during
Stage 1. The single exception is Phase 5 refuters, which may write fixtures in a
scratch directory the test runner can actually read, so a reproduction can be
real. They never touch a tracked file. Nothing else in Stage 1 writes anywhere.

---

### Phases 1 to 4

Read `references/phases.md` and run them in order. In brief:

1. Understand the codebase before opening the target file.
2. Map the target's upstream, downstream and siblings.
3. Run the project's mechanical checks, once each, per
   `~/.claude/shared/project-checks.md`. Never chain runners with `||`.
4. Deep analysis, three agents in parallel: design, failure modes, test coverage.

### Phase 5: Refutation (MANDATORY)

Every finding runs a gauntlet before it can be reported. A false finding costs
more of the user's attention than the agents cost.

#### Classify first

Tag each Phase 4 finding as one of two kinds. The bar differs because the
evidence differs. **Pass 1 may reclassify.** A refuter that finds a MECHANICAL
tag unprovable by construction says so, and the finding moves to JUDGMENT rather
than dying on its tag. A finding that is both, a misnamed method that also
returns an unguarded nil, splits into two findings, one of each kind. **A finding
carrying two separately falsifiable claims of the same kind also splits**, one
per claim; a refuter handed two claims will answer the easier one.

- **MECHANICAL** - something happens, or fails, or is reachable. A wrong command,
  a nil that is not guarded, a race, a missing index, an unhandled status.
  These are reproducible, and the bar is a reproduction.
- **JUDGMENT** - an absence or a shape. A missing test, a leaky abstraction, a
  name that misleads, a responsibility in the wrong object. These cannot be
  reproduced by construction, and demanding one would delete them silently while
  the score for design, readability and testability stayed high. That failure
  mode is worse than the findings are.

#### Batching (do not skip this)

At most 20 subagents may be **running at once**, and a spawn past that fails
without a retry. It is a concurrency ceiling, not a budget on the total. Passes 1 and 2 run together, so process findings in
**waves of at most 6** (12 concurrent). Finish a wave, **including its Pass 3 adjudications**, before starting the next.
Batching is required; it is the one thing here you may not do all at once.

The three refuter prompts are in `references/refutation.md`. Read it before
using the table below.

#### Resolution, with no ambiguity

First matching row wins, read top to bottom.

| Kind | Pass 1 | Pass 2 | Outcome |
|---|---|---|---|
| MECHANICAL | REPRODUCED | MATTERS | Pass 3 decides: CONFIRMED, NARROWED, or REFUTED |
| MECHANICAL | REPRODUCED | ALREADY-HANDLED, NO-CONSEQUENCE, or CONVENTION | Pass 3 decides, and may return REFUTED |
| MECHANICAL | GUARDED | any | **REFUTED.** Dropped. The guard is the refutation |
| MECHANICAL | NOT-CONSTRUCTIBLE | MATTERS | **Assumptions and Unknowns**, with what would be needed to test it. Never dropped |
| MECHANICAL | NOT-CONSTRUCTIBLE | ALREADY-HANDLED, NO-CONSEQUENCE, or CONVENTION | **REFUTED.** Pass 2 answered what Pass 1 could not stage |
| MECHANICAL | NOT-REPRODUCED | any | **REFUTED.** Dropped |
| MECHANICAL | RECLASSIFY | any | Re-run as JUDGMENT, both passes. Costs one extra wave slot |
| JUDGMENT | BASIS-ESTABLISHED | MATTERS | Pass 3 decides: CONFIRMED, NARROWED, or REFUTED |
| JUDGMENT | BASIS-ESTABLISHED | anything else | Pass 3 decides |
| any | a pass errored, timed out, or returned nothing | | Re-run it once. Still nothing: **UNVERIFIED**, to Assumptions with the reason. Never dropped silently |
| JUDGMENT | BASIS-FALSE | any | **REFUTED.** Dropped |

REFUTED findings are dropped silently. Do not list what you rejected.

Every surviving finding carries, verbatim:

- **Evidence-or-Reproduction** - for MECHANICAL, the command and its real output. For JUDGMENT,
  the quoted code and the fact established in Pass 1.
- **Verdict** - CONFIRMED or NARROWED, with the conditions for NARROWED.
- **Survived** - what Passes 2 and 3 tried and could not do.

**Report the pass rate**, split by kind. If eight mechanical findings entered and
three survived, say so. A high survival rate means Phase 4 was timid or the
refuters were soft, and both are worth knowing.

The three refuter prompts are in `references/refutation.md`. Prepend the
project's execution context to each, as that file explains.

### Phase 6: Synthesize and Score

**Goal:** Combine all findings into structured assessment.

Score each category 0-10. Be honest. Score what you see, not what's missing from a theoretical ideal.

Score the six categories per the weighted table in `references/output.md`.

### Scoring Guidance

- **9-10**: Excellent. Well-tested, clear intent, handles edge cases, production-ready. This is what good engineering looks like, do not treat it as unattainable.
- **7-8**: Good. Minor gaps but solid overall. Ship with confidence.
- **5-6**: Mediocre. Notable gaps in testing or error handling.
- **3-4**: Problematic. Significant issues need addressing before shipping.
- **0-2**: Broken or dangerous. Block until fixed.

**Calibration rule:** If the code has good test coverage, handles its edge cases, and reads clearly, that's an 8-9. Do NOT deduct points for hypothetical improvements or missing observability. Only deduct for concrete, demonstrable issues.

**Each score MUST have justification citing specific evidence.**

---

## ==================== STOP ====================
## Stage 1 ends here. Present the full assessment.
## Do NOT proceed to Stage 2 until the user responds.
## ==============================================

Worked findings, good and bad, are in `references/examples.md`.

## Stage 2: Action (Phase 7), USER DIRECTED

### Phase 7: Implement User Decisions

**Goal:** Execute the user's action plan. Only items the user approved.

After presenting the assessment output (everything from Phases 1-6), Claude MUST ask:

> Ready to work on individual findings? I'll present them one by one and you can decide what to do with each. At the end I'll create a todo list and resolve them.

**Wait for the user to confirm before presenting the first finding.**

Then present findings **one at a time**, waiting for the user's decision on each before showing the next.

**For each finding, present a self-contained block with:**

1. **Header** with ID, severity, and short title
2. **Evidence**, the file:line and the problematic code snippet
3. **Impact**, 1-2 sentences on what goes wrong and why it matters
4. **Verdict**, CONFIRMED or NARROWED with the conditions refutation established
5. **Survived**, what Passes 2 and 3 tried and could not do
6. **Proposed fix**, the concrete change, shown as code or clear description
7. A line asking: "fix, skip, or your own instructions?"

**Then STOP and wait for the user's response before presenting the next finding.**

**Example, first finding presented alone:**

```
### F1, Must-fix: Uncaught nil on API response

`external_client.rb:47`
```ruby
data = response.body["data"]
data.each do |metric|  # raises NoMethodError if data is nil
```

If the upstream returns empty or malformed JSON, `data` is nil and `.each` crashes
the entire sync job. No retry, no partial save, full data loss for this run.

**Verdict:** CONFIRMED, or NARROWED with the conditions that survived refutation

**Proposed fix:** Guard with early return:
```ruby
data = response.body["data"]
return log_warn("No data in response for #{account.id}") if data.blank?
```

fix, skip, or your own instructions?
```

After the user responds (e.g., "fix"), present F2. After F2's response, present F3. And so on.

**After ALL findings have been presented and the user has responded to each one**, Claude:

1. Creates tasks (via TodoWrite) for every finding the user approved
2. Works through the task list in finding-ID order

**CRITICAL:** Do NOT batch findings. Do NOT present F2 before the user has responded to F1. Do NOT create tasks or implement anything until every finding has a user decision.

---

**Precondition:** Every finding has been presented one-by-one and the user has responded to each. If any finding is still pending a response, do NOT proceed.

After all responses are collected, Claude:

1. **Creates tasks (via TodoWrite)** for each finding the user marked as "fix" or gave custom instructions for:
   - Subject: the finding ID and short description (e.g., "F1: Fix uncaught nil error in sync service")
   - Description: the full finding details + the user's instructions if any
   - Skipped items get no task

2. **Works through the task list in finding-ID order**, marking each task in_progress → completed as it goes.

3. **For each fix**, follows the finding's "Minimal Fix Direction" unless the user gave different instructions.

**CRITICAL:** Do NOT implement anything the user marked as "skip". Do NOT change the approach unless the user said to.

---

## Finding contract and output

The finding contract, the three required sections and the strict output
format are in `references/output.md`. **Read it before Phase 4**, not at Phase 6:
four of the seven finding elements are produced by the Phase 4 agents, and if
they were not told to collect them you arrive at the stop gate with incomplete
findings and no agent left to complete them. Read it before writing
anything. The checklists in `references/quality-bar.md` run before the stop
gate and again before Stage 2.

## Hard Constraints

- **Never skip a phase, and never skip a pass inside Phase 5, because you cannot
  spawn agents.** If spawning is unavailable, run them yourself in order and
  declare it. A phase silently dropped for want of an agent is the one failure
  this skill cannot detect in its own output.

- **Do NOT edit, write, or modify any file in the repository during Stage 1 (Phases 1-6).** The one exception is Phase 5 refuters, which may write fixtures to a runner-visible scratch directory and run the project's test and lint commands. They never touch a tracked file and never leave the repo dirty.
- **Do NOT skip the user prompt between Stage 1 and Stage 2.** You MUST present findings and wait for the user's response before implementing anything.
- Do NOT assume missing context, you MUST gather it in Phases 1-2
- Do NOT invent requirements
- If something depends on context you couldn't gather, FLAG IT EXPLICITLY
- Do NOT produce "best practices" lists without tying them to THIS code
- Do NOT skip phases, context gathering is mandatory
- Prefer precision over coverage
- **Follow existing conventions**, Before proposing fixes or tests, read sibling files to understand how the codebase does things. Do NOT introduce patterns, assertion styles, helper methods, or testing strategies that are not already used in the project. If the codebase uses `double("Stripe::Invoice")`, use that, don't suggest `instance_double` or `stub`. If specs use `context "when ..."`, follow that, don't switch to `describe`. Match the existing style exactly.

---

## Anti-Patterns (Do NOT Do These)

### Noise Findings, NEVER Report These
- **"Missing logger/logging"**, Unless there's a specific failure scenario where data is lost silently
- **"Add monitoring/observability"**, Generic observability advice is not a code defect
- **"Consider adding metrics"**, Not a finding
- **"Missing error notification"**, Unless errors are actively swallowed with no trace
- Any suggestion that starts with "Consider..." or "You might want to...", either it's a real issue or it's not

### Other Anti-Patterns
- Generic "you should add error handling" without specific evidence
- "Consider using X pattern" without explaining why it matters HERE
- Style nitpicks that don't affect correctness/maintainability
- Praise without evidence ("good use of...", why is it good?)
- Speculation about problems that might exist
- Best practices lists not tied to specific code
- Vague concerns ("this could be improved")
- **Skipping context gathering and jumping straight to code review**
- **Evaluating code without understanding what calls it or what it calls**
- **Proposing tests or fixes that use patterns not found in the existing codebase**
- **Implementing fixes without asking the user first**, The assessment is a report, not an action plan. Ask, then act.
- **Treating the assessment as a continuous flow that ends with fixes**, Stage 1 ends with output. Full stop. Stage 2 starts only after user input.

---

## Communication Style

- Short sentences. No filler.
- Direct, technical, evidence-based.
- If the code is good, say why with evidence. If it is bad, say why with evidence.
- Do not soften criticism and do not over-praise. The job is to evaluate the
  code, not to reassure the author.
