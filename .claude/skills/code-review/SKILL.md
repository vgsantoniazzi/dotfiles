---
name: code-review
description: Systematic code review examining correctness, security, performance, maintainability, and testing. Operator-mindset focused.
---

# Code Review Skill

Systematic approach to reviewing code changes across multiple dimensions.

## Core Review Areas

1. **Correctness** - Logic validation and edge case handling
2. **Security** - Vulnerability assessment including injection and exposure risks
3. **Performance** - Query optimization and resource efficiency
4. **Maintainability** - Code clarity, abstraction, and design principles
5. **Testing** - Coverage and test quality

## Operational Focus

Think like Joe Armstrong about failure modes. Consider who debugs this at 3am.

## Critical Red Flags

- Missing idempotency in background jobs
- Absent rollback paths for data modifications
- Silent failure handling without logging
- Race conditions and missing database indexes
- Hardcoded secrets

## Output Structure

- Risk assessment
- Critical issues
- Failure mode analysis
- Suggestions
- Positive observations
- Clarifying questions

## Language-Specific Checks

Support Ruby/Rails, JavaScript/TypeScript, and general patterns.

Emphasize constructive feedback that explains reasoning behind concerns.
