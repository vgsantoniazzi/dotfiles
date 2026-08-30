# The three refuter prompts, read at Phase 5

Stage 1 is read-only **on the repository**. A refuter may write fixtures to a
scratch directory and run the project's own test and lint commands. **The
scratch path must be visible to the test runner.** Where a project runs tests in
a container, a host `mktemp -d` is invisible to it, so a scratch inside the
container's own `/tmp` is usually a named volume the host cannot read either.
The path that works both ways is one inside the repo that is bind-mounted into
the runner and already gitignored, typically `tmp/`. Delete it when done. Verify the runner can read
the path before relying on it. It may never
edit, stage, or delete a tracked file, and never leaves the repo dirty. This is
the only Stage 1 exception, and it exists so reproduction can be real.

**Every refuter prompt carries the project's execution context**, resolved from
`~/.claude/shared/project-checks.md`: how to run tests and lint, which host
invocations are forbidden, where a scratch path must live to be visible to the
runner, and any suite behaviour that changes what a reproduction proves. Without
it a refuter runs a host toolchain against no database and reports confident
fiction. Prepend it to every template below.

All three passes use `Agent subagent_type=general-purpose`. Do not use
`Explore`: it has no Write tool, cannot build a fixture, and would return every
mechanical finding as unreproducible. **A refuter must not spawn subagents of its
own**; that is what breaches the concurrency cap.

### Pass 1 - Evidence

For MECHANICAL findings:

```
Make this finding happen, or declare it unreproducible.

FINDING: <claim, file:line, asserted consequence>

Run the command. Construct the input in a temp directory. If the finding says
something fails, make it fail and paste the output with its exit code. Reading
code is not evidence, and "it would obviously happen" is NOT-REPRODUCED.

Verdict, one of:
  REPRODUCED        - paste the command and its output.
  NOT-CONSTRUCTIBLE - the mechanism is real but this environment cannot stage it:
                      a multi-worker race, a third-party timeout behind a network
                      stub, a partial failure mid-transaction. Say what blocked
                      you and what would be needed.
  GUARDED           - you cannot stage it, but the code path that prevents it is
                      right there. Quote it. This is the one case where reading
                      code IS the refutation, and it outranks the rule above.
  NOT-REPRODUCED    - you staged it and it did not happen. That is a refutation.
  RECLASSIFY        - this is not a mechanical claim at all. It asserts a shape
                      or an absence, which no command can demonstrate. Say why,
                      and it is re-run once as JUDGMENT.

Check for a guard before declaring anything NOT-CONSTRUCTIBLE. A race with a
`with_lock`, a nil behind a guard clause, a timeout inside a rescue: these look
unstageable and are simply false.
```

For JUDGMENT findings:

```
Establish or deny this finding's factual basis. Do not argue taste.

FINDING: <claim, file:line, asserted consequence>

Prove the fact underneath the judgment. A missing test: name the code path and
show no spec exercises it. A misplaced responsibility: quote the method and the
layer it sits in. A misleading name: quote the name and what it actually does.

Verdict: BASIS-ESTABLISHED (quote the evidence) or BASIS-FALSE (say what is
actually there). If the fact holds, the judgment survives to Pass 2. Whether it
is worth acting on is not your call.
```

### Pass 2 - Prior art and consequence

Runs concurrently with Pass 1 and must not receive its verdict. Different
question: not "is it real" but "does it matter here".

```
This finding may be true and still worth dropping. Find out why.

FINDING: <claim, file:line, asserted consequence>

1. Is it already handled: a guard, validation, DB constraint, linter rule, test,
   framework default, hook, or CI step the finder did not look at?
2. Does the harm reach anyone? Who, when, and how would they notice?
3. Is it the codebase's deliberate convention? Check the siblings. Three files
   doing the same thing is a pattern, not three bugs.

Do not attempt to reproduce it; another agent owns that.

Verdict: MATTERS, ALREADY-HANDLED (name where), NO-CONSEQUENCE (say why), or
CONVENTION (cite the siblings).
```

### Pass 3 - Adjudication

Spawned by the Stage 1 orchestrator once both return, one per finding, after
its wave completes. It is the only agent that sees both verdicts.

```
Two agents examined this finding and may both be wrong.

FINDING: <claim>   KIND: <MECHANICAL or JUDGMENT>
PASS 1: <verdict and evidence>
PASS 2: <verdict and evidence>

Where they disagree, decide which is wrong and say why. Where they agree, look
hardest; agreement is also how two agents share a blind spot. Check the
reproduction demonstrates the claimed mechanism and not a coincidence. Check the
prior-art audit did not stop at the first plausible answer.

Final verdict: CONFIRMED, NARROWED (state the conditions), or REFUTED.
A REFUTED adjudication drops the finding whatever the earlier passes said.
```
