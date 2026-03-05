---
name: pull-request
description: Create pull requests with professional, readable descriptions and consistent branch naming.
---

# Pull Request Workflow

Standards for creating pull requests with professional, readable descriptions.

## Branch Format

All branches must follow: `vgsa/<descriptive-slug>`
- Lowercase, hyphen-separated
- Clearly communicates the change's purpose

## Description Style

PR bodies should prioritize readable prose rather than structured lists.
Descriptions should read as if explaining to a colleague who just sat down next to you.

## Content Structure

- Opening paragraph explaining what the change does and why
- Additional paragraphs covering technical details or trade-offs
- Bullet points only when necessary (process flows, broad scope, breaking changes)

## What to Avoid

- Never mention AI/Claude in PR descriptions
- No changelog-style lists of modified files
- No excessive formatting
- No obvious statements that add no value

## Workflow

1. Create branch with `vgsa/` prefix
2. Make commits using git-commit skill
3. Push with upstream tracking
4. Create PR using GitHub CLI with well-crafted description
5. Confirm with user before creation
6. Provide final PR URL
