---
name: debug-production
description: Systematic production debugging workflow. Log-driven, hypothesis-based, with verification steps.
---

# Production Debugging Workflow

The user excels at debugging from incomplete information. Use log-driven debugging and hypothesis formation/elimination to quickly narrow scope.

## Eight-Step Framework

### 1. Establish the Symptom
Clarify observed vs expected behavior, timing, affected users, and blast radius.

### 2. Gather Evidence
Collect logs, metrics, and recent changes using bash queries.

### 3. Form Hypotheses
Rank likely causes with supporting evidence.

### 4. Narrow Scope
Systematically eliminate possibilities through targeted queries.

### 5. Reproduce
Attempt reproduction in production, staging, or local environments.

### 6. Identify Root Cause
Document immediate cause, root cause, and contributing factors.

### 7. Fix with Verification
Write tests, verify the fix, monitor post-deployment.

### 8. Document & Prevent
Add findings to project documentation.

## Key Principle

"Don't deploy a fix you can't explain" and avoid assuming correlation equals causation.
