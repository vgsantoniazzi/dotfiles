---
name: tdd-bug-fix
description: Never modify production code to fix a bug without first writing a failing test that reproduces the issue.
---

# TDD Bug Fix Workflow

Core Practice: Never modify production code to fix a bug without first writing a failing test that reproduces the issue.

## Four-Step Process

1. **Reproduce** - Create a test demonstrating the bug
2. **Verify Red** - Confirm the test fails for the correct reason
3. **Fix** - Apply minimal production code changes
4. **Verify Green** - Ensure the test passes and no regressions occur

## Key Principle

The test serves triple duty: it proves the bug existed, confirms it's now resolved, and prevents future reintroduction.

## When to Apply

Use for any bug fix in production code.

Skip for: configuration files, infrastructure code, documentation, dependency locks, and codebases lacking test suites.

## Why It Matters

A bug fix without accompanying tests remains unproven, unprotected against regression, and undocumented.
