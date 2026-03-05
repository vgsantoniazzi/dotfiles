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
# For uncommitted changes
git diff
git diff --staged

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

### 3. Output Format

```markdown
## Code Review Summary

**Files Changed:** [count]
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

### Positive Notes
- [what was done well]

### Questions
- [clarifying questions for the author]
```

## Guidelines

- Be constructive, not critical
- Explain WHY something is an issue
- Provide concrete suggestions
- Acknowledge good patterns
- Distinguish between blocking issues and nice-to-haves
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
- Documentation for public APIs
- Error messages are helpful
- Logging is appropriate

## Red Flags to Always Flag

- Missing idempotency in background jobs
- No rollback path for data changes
- Silent failures (rescue without logging)
- Race conditions
- Missing indexes on queried columns
- Hardcoded secrets
