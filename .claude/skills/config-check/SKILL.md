---
name: config-check
description: Check whether the Claude config still works. Use when the user says check my config, audit my config, is my config still right, or asks why a skill or rule stopped firing. Executes every command the config names instead of reading them.
allowed-tools: Read, Glob, Grep, Bash, Agent
---

# Config check

Every defect ever found in this config existed because the config was written
and never executed. Reading it finds style problems. Running it finds real ones.

**The rule for this whole check: a claim about the config is worth nothing until
a command demonstrates it.** If you did not run it, you did not check it.

Run this quarterly, or when something that should fire stops firing.

## 1. Execute every command the config names

For each skill, command and agent under `~/.claude/`, extract every shell
command in a code fence. For each one, in each repo it can fire in:

- Does the binary exist on a hook-like `PATH`, not just your interactive shell?
- Does it run from the directory the skill implies, and from the repo root?
- What happens on empty input? A `$(...)` that expands to nothing turns a
  targeted command into a project-wide one, and with `-a` or `--fix` into a
  project-wide rewrite.
- Does a failure exit non-zero, or does it fall through and look like success?

Past finds: a mandatory lint gate that could not work from any directory across
133 invocations; a runner chain where `||` hid a failing suite behind the next
tool's absence; four skills invoking host Ruby in repos that forbid it, where it
passes against a different toolchain and reports a false green.

## 2. Verify every reference resolves

Every file path, tool name, skill name, agent type and command named anywhere in
the config. Tool names drift: confirm against the current docs rather than
memory. Check `references/` files exist and that nothing points at a deleted
skill.

## 3. Check the global files know nothing local

A global file may say what good looks like. It may not name a runner, a
directory layout, or a vendor. Grep `~/.claude/` for every runner and project
name you use. Each hit belongs in that project's CLAUDE.md.

## 4. Compare usage against what is installed

`~/.claude.json`, key `skillUsage`, is the only lifetime-complete source.
Transcripts cover a fraction of sessions and `history.jsonl` cannot see skill
invocations at all. For anything at zero, check whether the user asks for its
behaviour in words its description does not contain. A skill can be well written
and unreachable, and that is a naming problem, not a usage problem.

## 5. Check the layers do not contradict each other

Global CLAUDE.md against each project's, and both against the skills. Look for a
rule stated absolutely in one place and qualified in another, two skills that
disagree about the same operation, and any threshold stated with two different
numbers.

## 6. Cold-run it

Static analysis missed most of what mattered. Give a fresh agent the config and
one realistic task, tell it to record the literal commands the config told it to
run, and then to execute them and report what actually happened. Do this for the
highest-traffic path, which is commit and open a PR.

## 7. Refute your own findings

Before reporting, hand the findings to a fresh agent whose job is to disprove
them. Roughly a third will not survive. Report the survivors with the command
and its real output, and say how many entered and how many stood.

## Report

Order by whether it changes what an agent does, not by how bad it reads. For
each: the file and line, the command you ran, its actual output, and the fix.

State plainly what you could not check and why. A check you skipped and did not
mention is how this config rotted the first time.
