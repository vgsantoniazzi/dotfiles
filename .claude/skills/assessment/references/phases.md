# Phases 1 to 4, read when Stage 1 starts

## Phase 1: Understand the Codebase (BEFORE reading target file)

**Goal:** Know what kind of system this is, what patterns it uses, and how code typically flows.

Claude MUST gather this context FIRST:

```
1. Read project CLAUDE.md or README if exists
2. Identify the tech stack (framework, language version, key libraries)
3. Understand the directory structure and conventions
4. Check for existing patterns (how are similar things done elsewhere?)
```

**Spawn Agent: Codebase Explorer**
```
Agent subagent_type=Explore
Prompt: "Before I assess [target file], help me understand this codebase:
1. What is this project? (SaaS app, library, CLI tool, etc.)
2. What's the tech stack? (framework, key libraries, patterns)
3. What's the directory structure convention?
4. Are there similar files I should look at for comparison?
5. What testing patterns exist? (test framework, coverage, conventions)
6. Any project-specific conventions in CLAUDE.md or docs?"
```

**Output from Phase 1:**
- Project type and purpose
- Tech stack summary
- Key conventions identified
- Similar files for pattern comparison

---

## Phase 2: Understand the Target Code's Context

**Goal:** Know what the target code does, who uses it, and what it depends on BEFORE judging it.

Claude MUST map these relationships:

**Spawn Agent: Dependency Mapper**
```
Agent subagent_type=Explore
Prompt: "Map all relationships for [target file]:

UPSTREAM (what this code depends on):
- What does it import?
- What external services/APIs does it call?
- What configuration does it read?

DOWNSTREAM (what depends on this code):
- What files import/use this code?
- How many callers exist?
- Is this a leaf node or a critical path?

SIBLINGS (related code):
- Are there similar files doing similar things?
- What patterns do sibling files follow that this one should?

Return: file paths, line numbers, and relationship type for each."
```

**Output from Phase 2:**
- List of all imports/dependencies
- List of all callers/consumers
- Integration points and data flow
- Similar code for pattern comparison

---

## Phase 3: Run Mechanical Checks

**Goal:** objective data, plus an honest list of what did not run.

Resolve `DIR`, `LINT`, `TEST` from `~/.claude/shared/project-checks.md`, then
run each once, in `DIR`, recording its exit code.

Classify from the probe, never from the exit code:

| Probe | Exit | Report |
|---|---|---|
| runner found | 0 | pass |
| runner found | non-zero | the checks **failed**; quote the output, it is a finding |
| no marker for that stack | n/a | "no runner"; run nothing, substitute nothing |

Never chain runners with `||`. It fires on non-zero, so a genuinely failing
suite falls through to the next tool and the real result is lost. Exit codes
alone cannot separate absent from failing: a missing `package.json` and a red
suite both exit non-zero.

Also check: dedicated tests for the target file, its coverage, and linter
findings scoped to it.

**Output:** pass/fail counts with exit codes, coverage, linter findings, and an
explicit list of checks not run and why.

## Phase 4: Deep Analysis (Multi-Agent)

**Every agent prompt below must demand the finding contract from
`references/output.md`: Evidence as `file:line` plus the code, Why It Matters,
Minimal Fix Direction, and Test That Would Catch This. An agent not told to
collect them will not, and Phase 6 cannot back-fill them.**

**Goal:** Get expert-level analysis from multiple perspectives.

**NOW read the target file completely.** No skimming.

Claude MUST spawn these agents IN PARALLEL:

#### Agent 1: Distinguished Engineer Review
```
Agent subagent_type=distinguished-engineer
Prompt: "Review [target file] with full context:

CODEBASE CONTEXT:
[Include summary from Phase 1]

DEPENDENCY CONTEXT:
[Include summary from Phase 2]

THE CODE:
[Include full file content]

Challenge the design:
1. Is this the simplest solution? What would you delete?
2. What hidden complexity exists?
3. What assumptions could break?
4. What's the 10x better way?
5. Who debugs this at 3am?
6. Does this follow the patterns established elsewhere in this codebase?

Be direct. No fluff."
```

#### Agent 2: Failure Mode Analyst
```
Agent subagent_type=general-purpose
Prompt: "Analyze failure modes for [target file].

INTEGRATION CONTEXT:
[Include callers and dependencies from Phase 2]

THE CODE:
[Include full file content]

Analyze EXCLUSIVELY:
1. Nil/missing/malformed inputs - What if callers pass bad data?
2. Duplicate execution/race conditions - What if called twice rapidly?
3. Partial failures - What if dependencies fail mid-operation?
4. Time-related issues - Timeouts, stale data, ordering?
5. State inconsistency - Can state get corrupted?

For each scenario: Expected behavior vs Actual behavior.
List CONCRETE scenarios, not generic concerns."
```

#### Agent 3: Test Coverage Analyst
```
Agent subagent_type=general-purpose
Prompt: "Analyze test coverage for [target file].

EXISTING TESTS:
[Include test file content if exists, or note 'No dedicated tests']

TEST RESULTS:
[Include relevant test output from Phase 3]

THE CODE:
[Include full file content]

Analyze:
1. What code paths are tested?
2. What code paths are NOT tested?
3. What edge cases are missing?
4. Are the existing tests meaningful or just coverage padding?

Propose specific tests that would catch real bugs."
```

**Output from Phase 4:**
- Design concerns with evidence
- Failure mode scenarios
- Test coverage gaps

---
