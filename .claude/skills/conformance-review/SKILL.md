---
name: conformance-review
description: Audit a finished change against this repo's real conventions, naming, placement, framework grain, test idiom, and report what to delete. Findings must cite precedent that predates the diff and survive three adversarial lenses. Optionally orchestrates assessment and qa. Invoke deliberately ("conformance review", "/conformance-review"). Never auto-fires.
allowed-tools: AskUserQuestion, Bash, Read, Edit, Write, Glob, Grep, Agent, Skill
---

# Conformance Review

One question, at a hard bar: **does this change read like it was written by someone who already worked in this codebase, and what should be removed?**

Correctness is another skill's job. This one judges *fit*: names that don't match the neighbors, logic in the wrong layer, tests written in a dialect the suite doesn't speak, and code the change made redundant but left behind.

## Core Principle

> A convention you cannot point at in two sibling files **that predate this diff** is not a convention. It is your opinion wearing a uniform.

## The Corpus Rule (non-negotiable)

**A file the diff touches is never precedent.** Compute `git diff --name-only <base>...HEAD` before anything else; that list is excluded from every corpus, every grep, every citation.

Without this the skill measures the diff against itself and reports "clean" exactly where change is densest, a feature adding 16 files to one namespace *becomes* the local convention. Every citation must be checked with `git log -1 --format=%H -- <file>`; if the last commit that touched it is the diff under review, drop the citation.

When fewer than 2 unchanged siblings remain for a layer, emit `INSUFFICIENT PRECEDENT, n=<k>` and assign no confidence. That layer is unauditable this run, say so rather than inventing a rule.

## What This Is Not

| Skill | Its question | Tie-break |
|-------|--------------|-----------|
| `code-review` | Correct, secure, operable? | Its Maintainability checklist overlaps this skill. **It owns names that mislead about behavior; this skill owns names that disagree with sibling precedent.** Correctness/security is out of scope here. |
| `structural-review` | Architecturally rotting? | Owns responsibility sprawl, tangled control flow, coupling, duplication. This skill's placement lane borrows **its §3 (Boundary & layering) only**. |
| `simplify` | What can be collapsed, and fix it now? | The fast apply-it-yourself pass. This skill is the evidence-gated pass requiring a zero-caller proof and a user decision before any deletion. **Never run both on one diff.** |
| `assessment` | Scored whole-file quality | Optional lane; overlaps the test and deletion lanes by construction. |
| `qa` | Does it break at the edges, in a browser? | Optional lane. |
| `operational-review` | Who maintains this at 3am? | Out of scope. Chain it in Stage 2 when a fix touches jobs, money, auth, or data. |

Correctness or security found anyway gets one line under **Out of scope, found anyway**, never developed. **One exception:** a tenant-scope or authorization leak is reported as a full Must-fix, because in a multi-tenant repo "doesn't match the neighbors" and "leaks another customer's data" are the same finding.

## When to Use

A feature is built and specs are green, before `pull-request`. After a refactor. When inheriting someone else's branch.

## When NOT to Use

**Floor:** diffs under ~50 lines, config/docs/lockfiles, reading it yourself is faster.
**Ceiling:** above ~1500 changed lines or ~40 files, run it **per sub-project** and say so in Phase 0. A single pass over a squashed multi-commit PR under-reports, because the intermediate rationale is gone.

## Two Stages, Hard Boundary

| Stage | Phases | Mode | Claude may... |
|-------|--------|------|---------------|
| **1. Audit** | 0-6 | Read-only | Read, grep, run read-only lint/tests, spawn agents, report |
| **STOP** | | | **Present. Collect decisions. Wait.** |
| **2. Apply** | 7 | Write | Apply approved fixes through the severity chain |

Stage 1's read-only boundary is **instructed, not mechanical.** Lane and lens agents run as `general-purpose`, which carries the full tool set, the prohibition lives in their prompt and nowhere else, so every lane and lens prompt must state it. `Edit`/`Write` exist on this skill for Stage 2 and for artifacts only.

## Context Protection

Read-heavy work runs in subagents returning finding rows, never file dumps. Shared context goes to the **session scratchpad** if the harness provides one; otherwise to a path confirmed with `git check-ignore`. **Never create a new top-level directory in the repo**, a `tmp/` that isn't ignored at the root leaves untracked files in `git status` right before `pull-request`.

---

## Stage 1: Audit

### Phase 0, Scope + intent gate

**Nothing spawns until the user answers.** Agents launched on a misread premise are this skill's most expensive failure.

**0a. Scout (one `general-purpose` agent, it must judge and read prose, which `Explore` is not for).**

```
Agent subagent_type=general-purpose
Prompt: "Scope: <target, or 'git diff main...HEAD plus uncommitted'>. Return under 50 lines:
1. Changed files grouped by sub-project and layer. Include totals (files, +/- lines).
2. In two sentences: what does this change DO, and what guarantee does it make?
3. Which sub-projects are touched, is there a real UI surface (is qa even applicable)?
4. Read the FULL commit body / PR description / branch log. For each deviation from its
   neighbors, report file:line + the deviation + THE AUTHOR'S STATED RATIONALE if the prose
   gives one. Do not judge. Scale: 5 deviations under 500 changed lines, 10 under 2000, 15 above.
5. Every CLAUDE.md / conventions doc applying to the touched paths (paths only)."
```

**0b. Restate in prose, in the main thread.** What the change does, the guarantee it makes, the scope about to be audited, every assumption. List 0a's deviations here **as text**, the question round cannot hold them.

**0c. One `AskUserQuestion` round, four questions, max four options each:**

| # | Question | Options |
|---|----------|---------|
| 1 | Is that read of the intent and guarantee correct? | correct · close, the real guarantee differs · no, restate |
| 2 | Of the deviations listed above, which are deliberate? | none, flag everything · all of them are deliberate · some (say which) · this diff is too big, audit per sub-project |
| 3 | Include `assessment`? | State the cost: ~5 agents, full suite + project-wide lint, several minutes. |
| 4 | Include `qa`? | State the cost: 3 specialists, real DB seed, real browser, 20-60 cases, 10-30 min, **needs an already-healthy env, it cannot ask you anything mid-run**. If 0a found no UI surface, recommend skipping. |

Questions 3 and 4 are always separate and never assumed. Deliberate deviations are passed to every lane as *do not flag*; findings can also be dismissed later at Phase 6, so this question is a shortcut, not a commitment.

### Phase 1, Grain profile (one agent per sub-project, spawned in one message)

Add another agent per layer family when a sub-project spans more than four layers. One agent cannot honestly profile Rails services, jobs, serializers, RSpec, and a React app in one pass, it will emit a confident, partly fabricated profile that every lane then judges against.

```
Agent subagent_type=general-purpose
Prompt: "Build a conventions profile for <sub-project>, layers: <layers>.

CORPUS RULE. First compute `git diff --name-only <base>...HEAD`. Files in that list are NEVER
precedent. Verify each citation with `git log -1 --format=%H -- <file>`; drop it if the last
commit is the diff under review. Under 2 unchanged siblings for a layer → emit
'INSUFFICIENT PRECEDENT, n=<k>' and assign no confidence.

SOURCES, in priority order:
 1. Applicable CLAUDE.md / conventions docs, quote the rule + cite file:line.
    VERIFY BEFORE QUOTING: (a) `test -e` every path the rule names; (b) find >=1 code site that
    obeys it. A rule failing either is downgraded to SPLIT and listed under 'Stale conventions
    doc'. Docs rot; they are evidence, not scripture.
 2. The 3-5 nearest UNCHANGED siblings per layer (not per file).
 3. Repo-wide greps where the sibling sample is too small. State measured rates: 'N of M'.

CONFIDENCE: STATED (in a doc, and verified) · STRONG (>=2 unchanged siblings agree, no nearby
counter-example, inclusion rate >90%) · SPLIT (repo does it both ways, or inclusion rate <70%, NOT a convention, must never be enforced) · NEW (see below).

NEW-CONVENTION CHECK (required): does the diff establish a pattern in >=2 of its OWN new files
that has no precedent? Tag it NEW. A NEW convention is never a violation, report it once as
'this change introduces X, applied in N of M eligible sites'. Without this the skill flags every
file adopting a deliberately-new pattern, with maximum confidence, and is exactly wrong.

REPO LANDMINES (required): read every 'Gotchas' / 'Naming landmines' / 'Files to never touch'
section in the applicable docs. Emit each as a STATED convention WITH THE EXACT GREP that tests
it against this diff. A landmine with no executable check is decoration.

COVER: naming · layer map · framework idiom · test idiom · comment policy · error/logging.
Write to <artifact-dir>/grain-<sub-project>.md. Return counts per tier, all SPLIT entries, all
NEW entries, the Stale conventions doc section, and an UNAUDITABLE list: every layer that hit
INSUFFICIENT PRECEDENT, with the changed files sitting in it."
```

### Phase 2, Mechanical gate

**Skip entirely if `assessment` is opted in**, it runs the full suite and a project-wide lint; use its results.

For **each** touched sub-project: locate its documented commands, state the exact command **and working directory** before running, and scope tests by passing touched spec paths explicitly. Reproduce every command verbatim in the report. If the environment is unavailable, record `not run, <reason>` and continue; a red baseline is context, not a finding.

**Read every lint command before running it.** If it carries a write flag (`--fix`, `--write`, `-a`, `-i`), run the read-only equivalent instead and note the substitution. A documented "lint" script that rewrites source would break Stage 1's guarantee.

### Phase 3, Lanes (spawn in ONE message, in parallel, without Edit/Write)

```
Agent subagent_type=general-purpose
Prompt: "<Phase 0b restatement> · Confirmed intent: <Q1> · Deliberate, DO NOT FLAG: <Q2>
Grain profile: <artifact paths>. Corpus rule applies to every grep you run.
YOU ARE READ-ONLY: never call Edit or Write, never modify a file, not even to fix something obvious.
PRECEDENCE: grain.md > a loaded skill's rubric > generic best practice. A loaded skill states
general opinion; this repo's unchanged siblings state fact. Where they disagree, the repo wins.
Return rows only, in the Finding Contract format. A lane that finds nothing returns 'clean' with
what it checked, an empty lane is a result and must never be padded.
YOUR CHARTER: <charter>"
```

| Lane | ID | Charter |
|------|----|---------|
| **Naming** | `NAME-` | Classes/methods/variables that don't match sibling naming. Abbreviations. Generic verbs without context. Vendor names on surfaced identifiers. Serializer keys, route names, job class names inconsistent with the existing surface. Near-identical names in one namespace. |
| **Placement** | `PLACE-` | Code in the wrong layer; business logic in models, controllers, or jobs. Load `structural-review` and apply **§3 (Boundary & layering) only**, do not import its §1, §2, §4, §5, which that skill owns, and **skip its adversarial pass**; Lens 2 is this skill's single instance of that filter. Namespacing, tenant scope, and sub-app isolation are **not** in that rubric, take them from grain.md's STATED entries and cite the quoted line. Also: framework grain, hand-rolling what the framework provides, hidden control flow in callbacks, wrong queue, renames that orphan queued work. |
| **Tests** | `TEST-` | Specs not speaking the suite's dialect: factory idiom, doubles, helpers, unstubbed outbound HTTP, missing shared-example contracts, assertions that assert nothing, and coverage gaps on the Phase 0 guarantee. State every inclusion rate as `N of M`; below 70% it is SPLIT and must not be raised. Load `rails` for its Sidekiq section only, its remaining ~230 lines are RSpec opinion that **loses to grain.md**. |
| **Subtraction** | `DELETE-` | **The lane that matters most.** Methods, callers, routes, jobs, specs superseded but not deleted. Wrappers that only forward. Helpers duplicating an existing one. One-caller abstractions introduced now. Unused params, dead flags, config never read. Comments **added inside a method body**, first check for a codegen gem (`annotate`, `annotaterb`, `sorbet`) and exclude its blocks; file- and class-level design notes are documentation, not comments. Also **scope contamination**: files touched that serve no part of the confirmed intent, one row each, "split into its own commit". Report a removable-line count. |
| `assessment` | `ASSESS-` | Opt-in. Run **Stage 1 only**. Its STOP gate, its "ready to work findings?" prompt, its one-at-a-time presentation, and its entire Stage 2 are **suppressed**, this skill owns the only gate. Full report to the artifact dir; return rows only. |
| `qa` | `QA-` | Opt-in. Run **Stage 1 only**; its stop gate and Stage 2 are suppressed. It **may ask the user nothing**, if bring-up needs a human decision, abort the lane and report "qa skipped: <blocker>". |

**Untested joint.** The opt-in lanes instruct `assessment` and `qa` to suppress stop gates their
own text declares mandatory. This has never been exercised on a real run. If a lane stops to ask
the user anything, abort it, record `lane aborted, reached its own gate`, and continue the run
with the lanes that returned. Never answer another skill's gate on the user's behalf.

### Phase 4, Barrier, evidence gate, three lenses

**Lanes are a barrier.** All must return before 4a, because dedup is cross-lane and you cannot dedup against a lane that hasn't reported.

**4a. Dedup.** Same `file:line` + same root cause collapses into one finding, keeping every lane's ID as an alias. Renumber imported findings on arrival (`assessment F1` → `ASSESS-1`), preserving the original id in parentheses.

**4b. Evidence gate, typed by claim.** One rule would silently gut the subtraction lane, which is the point of the run.

| Claim | Required evidence | Failing it |
|-------|-------------------|------------|
| Convention violation | ≥2 **unchanged** sibling precedents at `file:line`, or one verified STATED rule. Not SPLIT, not NEW. | Killed → Near-miss list |
| Removal / redundancy | The grep returning zero remaining callers. | Killed → Near-miss list |
| Test gap | The specific untested path, tied to the Phase 0 guarantee. | Killed → Near-miss list |
| Imported (`ASSESS-`, `QA-`) | The cited evidence **reproduced**, re-run the command, or open the `file:line`. A claim is unreproducible only if the file **contradicts** it; absence of sibling precedent is not grounds to kill an imported finding, which was never generated against one. | Reported as **unreproducible** |

**4c. Three lenses, three agents total, not three per finding.** Each lens agent receives the full survivor list and returns one refute/sustain row per finding. Never spawn per-finding agents: the cost of verification must not scale with the skill's own productivity, or it gets run twice and never again. Judging the whole set also lets a lens weigh findings against each other.

| Lens | Refutes if |
|------|-----------|
| **1. Is the convention real?** | Hunts counter-precedent in unchanged files. The profile says SPLIT or NEW, or the rule is generic best practice rather than this repo's habit. |
| **2. Is the fix minimal and worth it?** | Apply this filter: is the problem verified with evidence, does the fix suit this codebase rather than a generic best practice, what unstated assumption is it resting on, and would you defend it to the author's face. Emit refute or sustain per finding rather than paraphrasing it. Refutes a rewrite where an extraction would do, a premature abstraction, or churn with speculative payoff. Also ranks the set: which findings do not deserve the reader's attention next to the others? |
| **3. What does the fix break?** | Greps callers. Refutes on behavior change, broken callers, or a wire boundary crossed without its contract: serializer key, route, job class name, queue, DB column, public API, frontend contract, **and any API schema artifact the repo maintains** (`openapi.yaml`, `schema.graphql`, `*.proto`), grep it for the changed key. **Deploy-shim exception:** a class with no callers whose body delegates to its replacement is a shim keeping in-flight jobs alive, not dead code, do not refute; reframe the fix as *delete after the queue drains*. If the repo's documented alias mechanism is missing, that is its own finding. |

Each lens defaults to refute when uncertain. **≥2 refute → killed.** Exactly 1 refute → survives with the dissent printed. Never hide a dissent.

### Phase 5, Completeness critic (one agent, one round, no recursion)

Given the diff, the profiles, and the survivors: *"Which touched file produced no finding, and is that right? Which convention in the profile was never checked? **Which named landmine in the conventions docs was never checked against this diff?** What would a reviewer who knows this codebase notice that these lanes structurally cannot see?"* Anything it raises re-enters the evidence gate, the critic gets no exemption.

### Phase 6, Report

```markdown
## Conformance Review
**Scope:** [files, sub-projects, +/- lines] · **Confirmed intent:** [one line]
**Lanes:** [...] · **Mechanical:** [exact commands + results, or "not run, reason"]

### Funnel
| Raised | Deduped | Killed at gate | Killed by lenses | Unreproducible | **Reported** |

### Must-fix / ### Should-fix
[full Finding Contract, dissents printed]

### Near-miss, unproven, judge yourself
[one-line titles of gate-killed findings, max 10. No development, no severity.
A funnel count is not falsifiable; this list is.]

### New conventions this change introduces
[each NEW entry: "introduces X, applied in N of M eligible sites"]

### Stale conventions doc
[rules in CLAUDE.md that name missing paths or contradict the code, a finding about the docs]

### Unaudited
[every layer with no eligible precedent: "N files in <layer> had 0 unchanged siblings (new
namespace), no convention could be established; these were NOT checked." First-of-its-kind
code is where drift starts, and the gate is strictest exactly there. Never let it read as clean.]

### Subtraction summary
**N lines removable across M files.** [file · what · lines]

### Out of scope, found anyway   ### Clean [one line]
```

**There is no Nice-to-have bucket.** If a finding isn't worth fixing before the PR, it isn't worth generating.

```
## ==================== STOP ====================
## Stage 1 ends here. Present the report.
## Do NOT edit any file until every finding has a decision.
## ==============================================
```

Ask for decisions **by severity group in one round**, this supersedes the one-at-a-time presentation `assessment` and `qa` mandate when invoked directly; imported findings are never re-presented individually. **One exception:** any finding whose row shows **Wire boundary ≠ none**, or that deletes a file, route, public method, or job class, is listed separately and needs its own explicit yes. **Group acceptance never covers an irreversible change.**

---

## Stage 2: Apply (Phase 7)

**Precondition:** every finding has a decision. Create one task per approved finding, then work in ID order.

| Fix kind | Chain |
|----------|-------|
| Behavior-changing | `tdd-bug-fix` (failing spec first) → fix → targeted specs → lint |
| Rename / move | apply → grep stale references → targeted specs → lint. Crossing a wire boundary means the contract change ships in the same commit, or stop and ask. **Renaming a job class requires the repo's alias mechanism updated in the same commit, if that file doesn't exist, the fix is rejected, not improvised.** |
| Deletion | delete → targeted suite for the area → lint. A deletion that turns a spec red is a failed removal proof: revert and report. |
| Test conformance | rewrite the spec → confirm it still fails against the pre-fix code where applicable |

**A fix requiring a migration is not applied here**, it goes back to the user with `migration-safety` named as the next step.

**Never add a code comment to an applied fix or a rewritten spec**, even where the rationale is subtle, rationale belongs in the commit message. Imported findings do not carry their source skill's fix chain; the table above is the only chain.

Then once, over the aggregate diff: `code-review`, plus `operational-review` if any fix touched jobs, money, auth, or data. Re-run the mechanical gate and report the delta. **Hand off:** commits go through `git-commit`, PRs through `pull-request`. This skill never commits, never pushes, never opens a PR.

Never implement anything unapproved. A finding discovered while fixing goes on the list for the user, not into the diff.

## Finding Contract

- **Evidence**, `file:line` + the offending code, quoted.
- **Convention claimed** + **precedent**, ≥2 unchanged `file:line`, or the verified STATED rule. Removal findings substitute the zero-caller proof.
- **Why it matters**, concrete maintenance cost. Who pays, when. Not "best practice".
- **Minimal fix direction**, smallest change that resolves it. Deletions state line count.
- **Test that protects the change**, for deletions and pure renames this is `existing suite, unchanged` plus the command proving it. Do not invent a test.
- **Behavior-changing**, yes/no. **Wire boundary**, none, or which.
- **Dissent**, the objection, if exactly one lens refuted.

## Hard Constraints

- **Never auto-fires.** Not on "review", not before commits. Explicit invocation only.
- The corpus rule is absolute: changed files are never precedent.
- **Precedence: grain.md > a loaded skill's rubric > generic best practice.** Two named overrides, a loaded skill demanding `instance_double` never overrides an existing `double(...)` precedent, and any loaded skill endorsing explanatory comments is void here.
- Stage 1 never edits. That boundary is prompt-enforced, not tool-enforced, every lane and lens prompt carries the prohibition explicitly, or it does not exist. Stage 1 asks exactly one round of four questions and nothing else. Stage 2 asks only when an approved fix needs a migration or an uncoordinated wire-boundary change.
- No finding without repo evidence. A SPLIT or NEW convention is not a convention.
- A layer with no eligible precedent is reported as **unaudited**, never as clean.
- Lanes judge fit, not correctness. Do not grow this skill into `code-review`.
- Verification never scales per-finding: three lens agents, always.
- Artifacts live outside the working tree or in a `git check-ignore`-confirmed path. Never committed.
- Display each finding's contract fields verbatim. Imported skills' full reports stay in the artifact dir, referenced by path, only their finding rows enter the report.

## Anti-patterns

- Citing a file the diff just added as precedent. This is the failure that makes the whole run a mirror.
- Quoting a CLAUDE.md rule without checking the paths it names still exist.
- Flagging every file that adopts a convention this change deliberately introduces.
- Flagging generated annotation blocks as comments.
- "There are two of these now, extract an abstraction." Two is not a pattern.
- Reporting missing observability, missing docs, or a hypothetical scale problem as a conformance finding.
- Running `assessment` or `qa` because the change "feels big". They are opt-in. Ask.
- Passing an imported finding through unverified because a skill produced it.

## Example Finding

*Illustrative only, these files exist in no repo.*

### DELETE-3, Must-fix: `Widgets::Recalculator#recalculate_all` is now dead

- **Evidence**, `app/services/widgets/recalculator.rb:44-71`, 28 lines.
- **Removal proof**, `grep -rn "recalculate_all" app/ spec/` returns the definition and its own spec. Its sole caller, `Widgets::RefreshJob#perform:19`, was replaced by `recalculate_for(widget)` in this diff.
- **Why it matters**, it still reads as a public entry point, so the next maintainer has two plausible paths and one silently recomputes every widget in the account. The spec keeps it green, which makes the trap look supported.
- **Minimal fix direction**, delete the method and its spec block. 28 + 14 = 42 lines.
- **Test that protects the change**, existing suite, unchanged: `<test command> spec/jobs/widgets/refresh_job_spec.rb`.
- **Behavior-changing**, no. **Wire boundary**, none.
- **Dissent (lens 2)**, "could be a maintenance-task entry point." Countered: no maintenance task references it.

## Communication Style

Short sentences. Numbers where they matter, funnel counts, removable lines, inclusion rates as `N of M`. Direct and high-conviction; do not soften. No praise padding: "Clean" is one line, never a section of compliments.
