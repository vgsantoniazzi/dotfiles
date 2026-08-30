---
name: tdd-bug-fix
description: Fix bugs using TDD. Write a failing test first, then fix. The test proves the bug existed and is now fixed.
---

# TDD Bug Fix Workflow

Fix bugs using test-driven development.

## Core Principle

> Never modify production code to fix a bug without first writing a failing test that reproduces the issue.

Aligned with Kent Beck: the test proves the bug existed and is now fixed.

## The Four Steps

### 1. Reproduce
Write a test that demonstrates the bug:

```ruby
it 'does not double-charge on concurrent requests' do
  order = create(:order)

  # Simulate the bug condition
  threads = 2.times.map do
    Thread.new { PaymentService.process(order) }
  end
  threads.each(&:join)

  # This fails because of the bug
  expect(Payment.where(order: order).count).to eq(1)
end
```

### 2. Verify Red
Run the test. Confirm it fails FOR THE RIGHT REASON.

```bash
# resolve the runner from ~/.claude/shared/project-checks.md
<project test command> spec/services/payment_service_spec.rb:42

# Expected: 1
# Got: 2
```

The failure message should match the bug description. If it fails for a different reason, adjust the test.

### 3. Fix
Make the MINIMAL production code change to fix the bug:

```ruby
def process(order)
  Order.transaction do
    order.lock!
    return if order.paid?

    Payment.create!(order: order)
    order.update!(status: :paid)
  end
end
```

### 4. Verify Green
Run the test. Confirm it passes:

```bash
# resolve the runner from ~/.claude/shared/project-checks.md
<project test command> spec/services/payment_service_spec.rb:42
# 1 example, 0 failures
```

Run the full suite to check for regressions:

```bash
rspec
```

## When This Applies

Use this workflow when:
- Fixing any bug in production code
- You say "let me fix..."
- You identify broken behavior
- You're about to change code to resolve an issue

## Exceptions

This does NOT apply to:
- Config files (.env, secrets, yml)
- Infrastructure (Dockerfile, CI config, deploy scripts)
- Documentation
- Dependency locks (Gemfile.lock)
- Data migrations (but DO test rollback path)
- Codebases without existing test suites

## Why This Matters

A bug fix without a test is:
- Not provably correct
- Not protected against regression
- Not documenting expected behavior

The test serves as:
1. Proof the bug existed
2. Proof the bug is fixed
3. Protection against reintroduction
4. Documentation of the expected behavior

## Example Session

```
User: "Users are getting charged twice on slow connections"

Claude: "I'll fix this using TDD. First, let me write a test that
reproduces the double-charge..."

[Writes test that simulates concurrent requests]

"The test fails as expected - it creates 2 payments. Now I'll add
row-level locking..."

[Adds locking to payment service]

"Test passes now. Running full suite..."

[All green]

"Fixed. The test will prevent this from happening again."
```

## Common Patterns

### Race Conditions
Test with threads or simulate concurrent state

### Timing Issues
Use `travel_to` to control time

### External API Failures
Stub the failure condition

### Edge Cases
Create the specific data state that triggers the bug
