---
name: assessment
description: Comprehensive, evidence-based code assessment. Evaluates correctness, design, reliability, and testability with weighted scores. Spawns multiple agents for thorough analysis. Runs tests and linter. Kent Beck and Martin Fowler would approve.
---

# Assessment Skill

Comprehensive, evidence-based code assessment. Your job is to evaluate source code, not praise it.

## Core Principle

> Evidence beats opinion. Precision beats coverage. Fewer, deeper insights are better than generic checklists.

If something is unclear, say so. If code is good, say why with evidence. No fluff.

## When to Use

- Before merging significant code
- When inheriting unfamiliar code
- Periodic codebase health checks
- Evaluating code quality objectively
- When you need a thorough, structured assessment

## Primary Goals (Priority Order)

1. **Correctness & edge cases** — Does the code behave correctly in real-world conditions?
2. **Maintainability & clarity** — Can another engineer safely modify this in 6 months?
3. **Reliability & failure modes** — How does it behave when things go wrong?
4. **Security & data safety** — Only if applicable and visible in the code
5. **Performance** — Only if a concrete issue is observable

Do NOT optimize for style unless it impacts the goals above.

---

## Assessment Process (5 Phases)

**CRITICAL:** Do NOT skip phases. Do NOT start evaluating code until you understand the system it lives in.

---

### Phase 1: Understand the Codebase (BEFORE reading target file)

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
Task subagent_type=Explore
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

### Phase 2: Understand the Target Code's Context

**Goal:** Know what the target code does, who uses it, and what it depends on BEFORE judging it.

Claude MUST map these relationships:

**Spawn Agent: Dependency Mapper**
```
Task subagent_type=Explore
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

### Phase 3: Run Mechanical Checks

**Goal:** Get objective data from automated tools.

Claude MUST run these in parallel:

```bash
# 1. Run full test suite
npm run test 2>&1 || yarn test 2>&1 || rspec 2>&1 || pytest 2>&1

# 2. Run linter on entire project (not just target file)
npm run lint 2>&1 || yarn lint 2>&1 || rubocop 2>&1

# 3. Check coverage if available
npm run test -- --coverage 2>&1 || yarn test --coverage 2>&1

# 4. Check for tests specific to target file
# Look for __tests__/[filename].test.* or [filename].spec.*
```

**Also check:**
- Does the target file have dedicated tests?
- What's the coverage for this specific file?
- Are there linter warnings specific to this file?

**Output from Phase 3:**
- Test pass/fail counts
- Coverage percentage (overall and for target file)
- Linter errors/warnings (overall and for target file)
- Whether dedicated tests exist for target

---

### Phase 4: Deep Analysis (Multi-Agent)

**Goal:** Get expert-level analysis from multiple perspectives.

**NOW read the target file completely.** No skimming.

Claude MUST spawn these agents IN PARALLEL:

#### Agent 1: Distinguished Engineer Review
```
Task subagent_type=distinguished-engineer
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
Task subagent_type=general-purpose
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
Task subagent_type=general-purpose
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

### Phase 5: Synthesize and Score

**Goal:** Combine all findings into structured assessment.

Score each category 0-10. Be honest. Most code is 5-7.

| Category | Weight | Score | Weighted |
|----------|--------|-------|----------|
| Correctness & edge cases | 30% | X/10 | X.X |
| Design & architecture | 20% | X/10 | X.X |
| Readability & intent clarity | 15% | X/10 | X.X |
| Testability / existing tests | 15% | X/10 | X.X |
| Reliability & failure handling | 10% | X/10 | X.X |
| Security & performance | 10% | X/10 | X.X |
| **TOTAL** | 100% | | **X.X/10** |

### Scoring Guidance

- **9-10**: Production-ready, exemplary. Rare.
- **7-8**: Solid. Minor issues. Ship with confidence.
- **5-6**: Acceptable. Has gaps. Common for real code.
- **3-4**: Problematic. Needs work before shipping.
- **0-2**: Broken or dangerous. Block until fixed.

**Each score MUST have justification citing specific evidence.**

---

## Finding Requirements (Mandatory)

Every issue or improvement MUST include ALL of:

### 1. Evidence
Quote the relevant snippet or clearly identify file:line.
```
// Example: src/services/auth.ts:47
const user = users.find(u => u.id === id)  // No null check
```

### 2. Why It Matters
Describe the REAL impact (bug, future risk, operational cost, confusion).
```
If no user found, subsequent code throws TypeError. This crashes the
request and returns 500 to the client instead of 404.
```

### 3. Minimal Fix Direction
Prefer small, safe changes. Avoid rewrites unless unavoidable.
```
Add early return: if (!user) return res.status(404).json({ error: 'User not found' })
```

### 4. Test That Would Catch This
Describe a concrete test (unit, integration, or edge case).
```
it('returns 404 when user not found', async () => {
  const res = await request(app).get('/users/nonexistent-id')
  expect(res.status).toBe(404)
})
```

**If any of these are missing, the finding is incomplete.**

---

## Hard Constraints

- Do NOT assume missing context — you MUST gather it in Phases 1-2
- Do NOT invent requirements
- If something depends on context you couldn't gather, FLAG IT EXPLICITLY
- Do NOT produce "best practices" lists without tying them to THIS code
- Do NOT skip phases — context gathering is mandatory
- Prefer precision over coverage

---

## Failure-Mode Analysis (Required Section)

Explicitly analyze how the code behaves under:

1. **Nil/missing/malformed inputs**
   - What happens if required params are missing?
   - What happens with unexpected types?

2. **Duplicate execution/retries/race conditions**
   - Is this idempotent?
   - What happens on concurrent calls?
   - Are there race conditions with shared state?

3. **Partial failures (external services, I/O, background jobs)**
   - What if the database write fails?
   - What if the external API times out?
   - What if the job crashes mid-execution?

4. **Time-related issues**
   - What happens with stale data?
   - Are there timeout issues?
   - Ordering dependencies?

5. **State inconsistency or transaction boundaries**
   - Are operations atomic?
   - What happens if interrupted?
   - Are there orphaned records scenarios?

List CONCRETE scenarios with expected behavior.

---

## Testing Evaluation (Required Section)

### Gap Analysis
Identify what existing tests miss:
- Untested branches
- Missing edge cases
- Integration gaps

### Propose Specific Tests

**3 Unit Tests:**
1. [Test name]: [What it proves]
2. [Test name]: [What it proves]
3. [Test name]: [What it proves]

**2 Integration Tests:**
1. [Test name]: [What it proves]
2. [Test name]: [What it proves]

**1 Nasty Edge-Case Test:**
1. [Test name]: [What it proves] — The "what could go wrong" test

Explain what each test proves.

---

## Assumptions & Unknowns (Required Section)

### Cannot Conclude From Code Alone
- [What's unclear or depends on external factors]

### Risks If Assumptions Wrong
- [What breaks if your assumptions are incorrect]

### Questions For Author
- [Specific questions you would ask before approving]

---

## Output Format (Strict)

```markdown
## Executive Summary
[Max 5 lines. What is this code? What's the verdict? What's the single biggest issue?]

## Codebase Context
[Brief summary of what you learned in Phase 1-2: project type, tech stack, how target fits in]

## Dependency Map
- **Imports:** [what this code depends on]
- **Callers:** [what depends on this code - count and key files]
- **Similar code:** [sibling files for pattern comparison]

## Scores

| Category | Weight | Score | Weighted | Justification |
|----------|--------|-------|----------|---------------|
| Correctness & edge cases | 30% | X/10 | X.X | [brief reason] |
| Design & architecture | 20% | X/10 | X.X | [brief reason] |
| Readability & intent clarity | 15% | X/10 | X.X | [brief reason] |
| Testability / existing tests | 15% | X/10 | X.X | [brief reason] |
| Reliability & failure handling | 10% | X/10 | X.X | [brief reason] |
| Security & performance | 10% | X/10 | X.X | [brief reason] |
| **TOTAL** | 100% | | **X.X/10** | |

## Test Results
- Overall: [pass/fail counts]
- Target file tests: [exist? pass/fail?]
- Coverage: [percentage if available]

## Linter Results
- Overall: [error/warning counts]
- Target file: [specific issues]

## Must-Fix Issues
[Blocking issues. Each with: Evidence, Why It Matters, Fix Direction, Test]

## Should-Fix Issues
[Important but not blocking. Same format.]

## Nice-to-Have Improvements
[Minor improvements. Brief format acceptable.]

## Failure-Mode Analysis
[Concrete scenarios under each failure category]

## Testing Recommendations
- Gap Analysis: [what's missing]
- 3 Unit Tests: [specific proposals]
- 2 Integration Tests: [specific proposals]
- 1 Nasty Edge-Case: [specific proposal]

## Assumptions & Unknowns
- Cannot conclude: [list]
- Risks if wrong: [list]
- Questions for author: [list]
```

---

## Anti-Patterns (Do NOT Do These)

- Generic "you should add error handling" without specific evidence
- "Consider using X pattern" without explaining why it matters HERE
- Style nitpicks that don't affect correctness/maintainability
- Praise without evidence ("good use of..." — why is it good?)
- Speculation about problems that might exist
- Best practices lists not tied to specific code
- Vague concerns ("this could be improved")
- **Skipping context gathering and jumping straight to code review**
- **Evaluating code without understanding what calls it or what it calls**

---

## Quality Bar

Before finalizing the assessment, verify:

- [ ] Phase 1 completed: Codebase context gathered
- [ ] Phase 2 completed: Dependencies and callers mapped
- [ ] Phase 3 completed: Tests and linter run
- [ ] Phase 4 completed: Multi-agent deep analysis done
- [ ] Every finding has all 4 required elements (evidence, impact, fix, test)
- [ ] Scores have justification with specific evidence
- [ ] Failure-mode analysis covers all 5 categories with concrete scenarios
- [ ] Testing recommendations are specific and actionable
- [ ] Assumptions are explicitly flagged
- [ ] No generic advice
- [ ] Would Kent Beck approve the testing analysis?
- [ ] Would Martin Fowler approve the design analysis?
- [ ] Would Joe Armstrong approve the failure-mode analysis?

---

## Example Finding (Good)

```markdown
### Must-Fix: Uncaught Promise Rejection

**Evidence:**
`src/api/orders.ts:89`
```typescript
async function processOrder(orderId: string) {
  const order = await db.orders.findById(orderId)
  await paymentService.charge(order.amount)  // No try-catch
  await db.orders.update(orderId, { status: 'paid' })
}
```

**Why It Matters:**
If `paymentService.charge()` throws, the error bubbles up as unhandled rejection.
The order remains in limbo state (not marked paid, but payment may have succeeded).
Customer gets charged but order shows as unpaid. Manual intervention required.

**Minimal Fix:**
```typescript
try {
  await paymentService.charge(order.amount)
  await db.orders.update(orderId, { status: 'paid' })
} catch (error) {
  await db.orders.update(orderId, { status: 'payment_failed', error: error.message })
  throw error  // Re-throw for caller handling
}
```

**Test That Would Catch This:**
```typescript
it('marks order as payment_failed when charge throws', async () => {
  paymentService.charge.mockRejectedValue(new Error('Card declined'))
  await expect(processOrder('order-123')).rejects.toThrow('Card declined')
  const order = await db.orders.findById('order-123')
  expect(order.status).toBe('payment_failed')
})
```
```

## Example Finding (Bad — Do Not Do This)

```markdown
### Should Consider: Error Handling

You should add try-catch blocks around async operations for better error handling.
This is a best practice that improves reliability.
```

This is bad because: no evidence, no specific location, no impact analysis, no test proposal.

---

## Communication Style

- Write clearly. Short sentences.
- No fluff. No filler words.
- Direct. Technical. Evidence-based.
- If the code is good, say why with evidence.
- If the code is bad, say why with evidence.
- Do not soften criticism. Do not over-praise.
