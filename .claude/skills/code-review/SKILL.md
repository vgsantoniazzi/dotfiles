---
name: code-review
description: Review pull requests, diffs, and uncommitted changes. Provides structured feedback on code quality, security, operational concerns, and best practices.
---

# Code Review Skill

Review code changes systematically, providing structured feedback.

## When to Use

- Reviewing pull requests
- Reviewing staged/unstaged changes
- Before committing code
- When user asks for feedback on code

## Review Process

### 1. Gather Context

```bash
# For uncommitted changes, including untracked files
git status --porcelain
git diff
git diff --staged
# For a branch
git diff $(git merge-base HEAD "$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)")...HEAD

# For a PR
gh pr view [number] --json additions,deletions,files
gh pr diff [number]
```

### 2. Review Checklist

#### Correctness
- [ ] Does the code do what it claims to do?
- [ ] Are edge cases handled?
- [ ] Are there any logic errors?

#### Security
- [ ] SQL injection vulnerabilities?
- [ ] XSS vulnerabilities?
- [ ] Sensitive data exposure?
- [ ] Authentication/authorization issues?

#### Performance
- [ ] N+1 queries?
- [ ] Unnecessary database calls?
- [ ] Memory leaks?
- [ ] Blocking operations?

#### Maintainability
- [ ] Clear naming?
- [ ] Appropriate abstraction level?
- [ ] DRY violations?
- [ ] Single responsibility?

#### Testing
- [ ] Are there tests for new functionality?
- [ ] Do tests cover edge cases?
- [ ] Are tests readable?

#### Operational Concerns
For significant changes, run `operational-review` skill for full assessment. Quick checks:
- [ ] Idempotent? (jobs, APIs, CRUD operations)
- [ ] Rollback path exists?
- [ ] Failure modes handled?

### 3. Refute before reporting (MANDATORY)

Findings that turn out to be wrong cost more attention than the check costs.
Before the report, spawn ONE fresh `Agent subagent_type=general-purpose` over
the whole finding set. Not one per finding; this skill runs often and must stay
proportionate. `assessment` is the heavier three-pass version when you need it.

```
Disprove as many of these findings as you can. Assume each is wrong.

FINDINGS: <numbered list: claim, file:line, asserted consequence>

For each: is the premise true in this repo at this version? Is it already
handled by a guard, validation, DB constraint, linter rule, test, framework
default, or CI step? Does the stated harm actually reach anyone? Is it the
codebase's deliberate convention rather than a mistake, and do the siblings
agree? For anything that claims something fails, run it and paste the output.

Verdict per finding: REFUTED (say why), NARROWED (state the conditions), or
STANDS (say what you tried).
```

Drop REFUTED findings silently. Report NARROWED with its conditions inline.

**Every Critical Issue carries a reproduction**: the command and its real
output, or the exact input that triggers it. A Critical Issue you cannot
reproduce moves to Suggestions. Structural and readability findings are exempt;
they assert a shape, not a failure, so quote the code instead.

State how many findings entered this pass and how many survived.

### 4. Output Format

```markdown
## Code Review Summary

**Files Changed:** [count]
**Refutation:** [N] findings entered, [M] survived
**Risk Level:** LOW | MEDIUM | HIGH
**Rollback Complexity:** Simple | Moderate | Complex

### Critical Issues
- [file:line] [issue description]

### Failure Modes to Consider
- [scenario]: [what happens]

### Operational Gaps
- [missing observability/logging/idempotency]

### Suggestions
- [file:line] [suggestion]

### Questions
- [clarifying questions for the author]
```

## Guidelines

**Report every issue you find, at every severity.** Do not pre-filter, soften,
or balance while generating. Assign severity as a label after the list is
complete. The only removal is a REFUTED verdict from step 3.


- Explain WHY something is an issue
- Provide concrete suggestions
- Display the FULL review output - never summarize
- Think like Joe Armstrong about failure modes
- Consider who debugs this at 3am

## Language-Specific Checks

### Ruby/Rails
- Strong params usage
- N+1 query detection
- Service object patterns
- Proper error handling
- Sidekiq job idempotency
- Silent failures (rescue without logging)

### JavaScript/TypeScript
- Type safety
- Async/await usage
- Memory management
- React hook rules

### General
- Consistent formatting
- Error messages are helpful
- Logging is appropriate

## Red Flags to Always Flag

- Missing idempotency in background jobs
- No rollback path for data changes
- Silent failures (rescue without logging)
- Race conditions
- Missing indexes on queried columns
- Hardcoded secrets
