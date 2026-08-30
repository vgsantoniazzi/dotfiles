# Finding contract, required sections, strict output format

## Finding Requirements (Mandatory)

Every finding must survive Phase 5 refutation and carry its reproduction.
The bar is not "a careful reader would agree". The bar is "an agent paid to
disprove this tried and failed".


Every issue or improvement, including nice-to-have, MUST include ALL of:

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

**Plus the three Phase 5 elements: Evidence-or-Reproduction (kind-aware),
Verdict, and Survived. Seven in total. If any are missing, the finding is
incomplete.**

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

**CRITICAL:** Before proposing any test, read 2-3 existing spec files in the same directory. Match their exact conventions: how they set up doubles, how they structure contexts, what assertion patterns they use. Proposed tests that introduce unfamiliar patterns are rejected.

**3 Unit Tests:**
1. [Test name]: [What it proves]
2. [Test name]: [What it proves]
3. [Test name]: [What it proves]

**2 Integration Tests:**
1. [Test name]: [What it proves]
2. [Test name]: [What it proves]

**1 Nasty Edge-Case Test:**
1. [Test name]: [What it proves], The "what could go wrong" test

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

- Not run: [check, and why it could not run]
- Overall: [pass/fail counts]
- Target file tests: [exist? pass/fail?]
- Coverage: [percentage if available]

## Linter Results

- Not run: [check, and why it could not run]
- Overall: [error/warning counts]
- Target file: [specific issues]

## Refutation

Execution: multi-agent, or single-threaded if agents were unavailable.

Findings entering Phase 5, split by kind: MECHANICAL N/M, JUDGMENT N/M.
Routed to Assumptions as NOT-CONSTRUCTIBLE or UNVERIFIED: K. (A high survival rate means
Phase 4 was timid or the refuters were soft.)

## Must-Fix Issues
[Blocking issues. Each finding prefixed with ID: F1, F2, F3...
Each with: Evidence, Why It Matters, Fix Direction, Test, Evidence-or-Reproduction (MECHANICAL: the command and its real output. JUDGMENT: the quoted code and the fact Pass 1 established), Verdict (CONFIRMED or NARROWED), Survived (what passes 2 and 3 tried)]

## Should-Fix Issues
[Important but not blocking. Continue numbering: F4, F5...
Same full format as Must-Fix.]

## Nice-to-Have Improvements
[Minor improvements. Continue numbering: F6, F7...
Same full format as Must-Fix. No shortcuts.]

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

## Action Summary

| ID | Severity | Finding |
|----|----------|---------|
| F1 | Must-fix | [short description] |
| F2 | Should-fix | [short description] |
| F3 | Nice-to-have | [short description] |
| ... | ... | ... |
```

---
