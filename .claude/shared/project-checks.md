# Project checks

How a global skill finds a repo's lint and test commands. No global skill may
hardcode a runner. The repo owns the verb.

## Resolution order

1. **CI config** first. What CI runs is the gate you must pass, and it outranks
   docs, which drift. Look in `.github/workflows/`, `.buildkite/`, `.circleci/`,
   `.gitlab-ci.yml`, and `Makefile`.

   **A CI file that runs no test and no linter is not the gate.** A repo can
   carry a dozen workflow files that only label, automerge or close stale pull
   requests while its real pipeline lives elsewhere. Grep the candidates for a
   test or lint invocation before believing any of them, and if none has one,
   you have not found CI yet. Keep looking rather than resolving to the first
   file you matched.
2. **The project's CLAUDE.md**: root, `.claude/`, and per sub-project.
3. **Detect**, only if 1 and 2 say nothing.

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
ls -1 CLAUDE.md .claude/CLAUDE.md */CLAUDE.md */.claude/CLAUDE.md \
      .github/workflows/*.yml Makefile justfile \
      dip.yml */dip.yml Gemfile */Gemfile package.json */package.json \
      pyproject.toml go.mod Cargo.toml 2>/dev/null || true
```

Bind per sub-project: `DIR` where the runner lives, `LINT`, `TEST`. Assign them
as shell variables before running anything. An unset `LINT` makes `xargs` fall
back to `echo`, which prints filenames and exits 0 having linted nothing.

## Rules

- **Run each check once and report its exit code.** Never `a || b || c`.
  Non-zero means the check *failed*; falling through discards that answer.
- **"Absent" is decided by the probe, never by an exit code.** `npm test` with
  no `package.json` exits 254, which looks identical to a failing suite. If the
  probe found no marker, say "no runner", run nothing, substitute nothing.
- **A containerised runner config present means every command for that stack
  goes through it.** A host
  `bundle exec` can pass silently against a different toolchain and tell you
  nothing about the container.
- **Run from `DIR`, with `DIR`-relative paths.** `git diff --name-only` is
  repo-root-relative from every cwd. `cd $DIR` first, then add `--relative`.
- **Guard every `$(...)` file list.** An empty expansion turns a targeted check
  into a whole-project one, and with `-a` or `--fix`, a whole-project rewrite.
