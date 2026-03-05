---
name: operational-review
description: Assess the operational burden of proposed changes. Who maintains this at 3am? How do we know it's broken?
---

# Operational Review Skill

Assess the operational burden of proposed changes.

## Core Principle

> Ask: Who maintains this at 3am? How do we know it's broken?

## When to Use

- Before implementing significant features
- When reviewing architecture decisions
- After completing work, before merging
- When inheriting unfamiliar code

## The Five Operator Questions

### 1. Who Maintains This?
- Is ownership clear?
- What expertise is required?
- What happens when that person is unavailable?
- Is there documentation?

### 2. How Do We Know It's Working?
- What metrics indicate success?
- Are there health checks?
- What does "normal" look like?
- Can we distinguish "working" from "working correctly"?

### 3. How Do We Know It's Broken?
- What alerts exist?
- What are the failure signatures?
- How quickly will we know?
- Who gets notified?

### 4. How Do We Fix It Under Stress?
- What's the runbook?
- Can we restart/retry safely?
- What are the common failure modes?
- What's the blast radius?

### 5. Can We Roll Back?
- Is there a rollback path?
- What's the rollback complexity?
- What data is lost on rollback?
- How long does rollback take?

## Operational Burden Assessment

Rate each area: LOW | MEDIUM | HIGH

### Observability
- [ ] Logging: Are failures logged with context?
- [ ] Metrics: Are key indicators tracked?
- [ ] Tracing: Can we follow a request through the system?
- [ ] Alerting: Do we know when it breaks?

### Maintenance
- [ ] Dependencies: How many? How stable?
- [ ] Updates: How painful are version bumps?
- [ ] Documentation: Can someone new understand this?
- [ ] Complexity: Is this simpler than alternatives?

### Reliability
- [ ] Failure modes: Are they handled gracefully?
- [ ] Idempotency: Is it safe to retry?
- [ ] Data integrity: Can it corrupt state?
- [ ] Graceful degradation: What happens under load?

### Debuggability
- [ ] Error messages: Are they actionable?
- [ ] State inspection: Can we see what's happening?
- [ ] Reproducibility: Can we recreate issues locally?
- [ ] History: Can we see what happened?

## Output Format

```markdown
## Operational Review: [Component/Feature]

**Overall Burden:** LOW | MEDIUM | HIGH
**Primary Risk:** [Biggest operational concern]

### Observability
**Rating:** [LOW/MEDIUM/HIGH]
- Logging: [assessment]
- Metrics: [assessment]
- Alerting: [assessment]
**Gaps:** [what's missing]

### Maintenance
**Rating:** [LOW/MEDIUM/HIGH]
- Complexity: [assessment]
- Documentation: [assessment]
- Dependencies: [assessment]
**Gaps:** [what's missing]

### Reliability
**Rating:** [LOW/MEDIUM/HIGH]
- Failure handling: [assessment]
- Idempotency: [assessment]
- Data integrity: [assessment]
**Gaps:** [what's missing]

### Debuggability
**Rating:** [LOW/MEDIUM/HIGH]
- Error messages: [assessment]
- State inspection: [assessment]
- Reproducibility: [assessment]
**Gaps:** [what's missing]

### Recommendations
1. [Most important operational improvement]
2. [Second priority]
3. [Third priority]

### Runbook Items Needed
- [ ] [What documentation is missing]
- [ ] [What alerts need to be created]
- [ ] [What metrics need to be added]
```

## Common Operational Gaps

### Background Jobs
- Missing: job-specific logging with correlation IDs
- Missing: metrics on queue depth, processing time
- Missing: alerts on retry storms
- Missing: idempotency guarantees

### External API Integrations
- Missing: circuit breakers
- Missing: timeout configuration
- Missing: retry logic with backoff
- Missing: fallback behavior

### Data Processing
- Missing: progress indicators
- Missing: partial failure handling
- Missing: resumability
- Missing: validation before commit

### Scheduled Tasks
- Missing: overlap protection
- Missing: completion notifications
- Missing: failure alerts
- Missing: runtime monitoring

## Anti-Patterns to Flag

- "It's obvious how this works" (no documentation)
- "We'll add logging later" (observability debt)
- "It should never fail" (no error handling)
- "We can always fix it in production" (no local reproducibility)
- "Someone will remember" (tribal knowledge)

## Questions for the User

If assessment reveals gaps:
1. "This lacks [X]. Want me to add it now or create a task?"
2. "There's no alert for [Y]. Who should be notified on failure?"
3. "The rollback path is unclear. Should we document it?"
