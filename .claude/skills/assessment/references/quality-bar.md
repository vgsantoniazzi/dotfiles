# Checklists, read before the stop gate and before Stage 2

## Quality Bar

- [ ] Every phase ran. If agents were unavailable, each was run single-threaded
      and the report says so, in the Refutation section

### Before presenting the assessment (end of Stage 1), verify:

- [ ] Phase 1 completed: Codebase context gathered
- [ ] Phase 2 completed: Dependencies and callers mapped
- [ ] Phase 3 completed: Tests and linter run
- [ ] Phase 4 completed: Multi-agent deep analysis done
- [ ] Phase 5 completed: every finding classified, refuted in waves of at most 6, adjudicated
- [ ] Every finding carries all 7 elements (evidence, impact, fix, test, evidence-or-reproduction, verdict, survived)
- [ ] Pass rate reported, split by MECHANICAL and JUDGMENT
- [ ] Every finding has an ID (F1, F2, F3...)
- [ ] Scores have justification with specific evidence
- [ ] Failure-mode analysis covers all 5 categories with concrete scenarios
- [ ] Testing recommendations are specific and actionable
- [ ] Assumptions are explicitly flagged
- [ ] No generic advice
- [ ] Action Summary table included with all finding IDs
- [ ] Would Kent Beck approve the testing analysis?
- [ ] Would Martin Fowler approve the design analysis?
- [ ] Would Joe Armstrong approve the failure-mode analysis?

### Before implementing anything (Stage 2 gate), verify:

- [ ] Assessment was presented in full to the user
- [ ] Each finding was presented one-by-one with evidence, impact, and proposed fix
- [ ] User has responded to EVERY finding before any task was created
- [ ] Tasks were created ONLY for findings the user approved
- [ ] No source code was modified during Stage 1

---
