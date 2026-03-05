---
name: debug-production
description: Systematic production debugging workflow. Log-driven, hypothesis-based, with verification steps.
---

# Production Debugging Workflow

Systematic approach to debugging production issues.

## Philosophy

The user is very good at debugging from partial information. They value:
- Log-driven debugging
- Hypothesis formation and elimination
- Narrowing scope quickly
- Asking the right diagnostic question

You can be technical, skip beginner explanations, show raw queries.

## Step 1: Establish the Symptom

Before diving in, clarify:
- What is the observed behavior?
- What is the expected behavior?
- When did it start? (deploy? time-based? load-based?)
- Who is affected? (all users? specific segment? one user?)
- What's the blast radius?

## Step 2: Gather Evidence

### Logs
```bash
# Recent application logs
tail -500 log/production.log | grep -i error

# Sidekiq logs (if job-related)
# Check your log aggregator for job failures

# Specific request/job
grep "REQUEST_ID_OR_JOB_ID" log/production.log
```

### Metrics
- Error rate spike?
- Latency increase?
- Database connection pool exhaustion?
- Memory/CPU anomaly?
- Queue depth growing?

### Recent Changes
```bash
# Recent deploys
git log --oneline -20

# What changed in last deploy
git diff PREVIOUS_SHA..CURRENT_SHA --stat
```

## Step 3: Form Hypotheses

Based on evidence, form ranked hypotheses:

```markdown
1. [Most likely] - [Evidence supporting]
2. [Second likely] - [Evidence supporting]
3. [Less likely but check] - [Evidence supporting]
```

For each hypothesis, identify:
- How to confirm or eliminate it
- What data would prove/disprove it

## Step 4: Narrow Scope

Systematically eliminate hypotheses:

```bash
# Check if issue is data-specific
# Query for affected records
bin/rails runner "puts User.where(id: AFFECTED_IDS).pluck(:status, :created_at)"

# Check if issue is time-bound
# Query logs around the time

# Check if issue is code-path specific
# Add temporary logging if needed
```

## Step 5: Reproduce (If Possible)

Can you reproduce in:
1. Production (carefully, with specific user/data)?
2. Staging (with production data snapshot)?
3. Local (with specific data setup)?

If reproduction requires specific data:
```bash
# Export relevant records
bin/rails runner "puts User.find(ID).attributes.to_json"
```

## Step 6: Identify Root Cause

Document clearly:
- **Immediate cause**: What directly caused the error
- **Root cause**: Why that happened
- **Contributing factors**: What made it possible

## Step 7: Fix with Verification

Before deploying fix:
1. Write a test that reproduces the bug (if possible)
2. Verify test fails before fix
3. Apply minimal fix
4. Verify test passes
5. Consider: what else could break?

After deploying:
1. Monitor error rate
2. Verify affected users/data are fixed
3. Check for regressions

## Step 8: Document & Prevent

Add to CLAUDE.md or project docs:
```markdown
### [Date] - [Issue Title]
**Symptom:** [What was observed]
**Root cause:** [Why it happened]
**Fix:** [What was done]
**Prevention:** [How to avoid recurrence]
**Detection:** [How to catch earlier next time]
```

## Common Patterns

### Sidekiq Job Failures
```bash
# Check retry queue
bin/rails runner "puts Sidekiq::RetrySet.new.size"

# Inspect failed jobs
bin/rails runner "Sidekiq::RetrySet.new.first(5).each { |j| puts j.item }"

# Check for retry storms
# Look for same job ID failing repeatedly
```

### N+1 Queries Causing Timeouts
```bash
# Check slow query log
# Look for repeated similar queries

# Add includes/preload to fix
```

### Race Conditions
- Look for timing-dependent failures
- Check for concurrent requests to same resource
- Verify idempotency of operations

### Third-Party API Failures
```bash
# Check external service status
# Look for timeout patterns
# Verify API credentials haven't expired
```

## Red Flags

- Don't deploy a fix you can't explain
- Don't assume correlation is causation
- Don't skip verification after fix
- Don't forget to document
