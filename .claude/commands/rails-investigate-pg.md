---
name: rails-investigate-pg
description: Systematic debugging for Rails PostgreSQL connection issues. Checks installation method, logs, configuration, and connectivity.
---

# PostgreSQL Connection Issues Investigation

Structured debugging approach for Rails developers encountering PostgreSQL connectivity problems.

## Step 1: Identify Error Messages
Examine Rails logs for connection-related failures like "connection refused" or authentication errors.

## Step 2: Detect Installation Method
Determine if PostgreSQL is running via Homebrew, Postgres.app, Docker, or system install.

## Step 3: Installation-Specific Diagnostics
Check service status, review logs, and apply fixes relevant to each deployment method.

## Step 4: Common Problems
Address port conflicts, missing socket files, configuration mismatches, and credential issues.

## Step 5: Rails-Specific Verification
Use `bin/rails runner` commands to confirm the connection is functioning.

## Step 6: Document Resolution
Record root cause and solution to prevent recurrence.
