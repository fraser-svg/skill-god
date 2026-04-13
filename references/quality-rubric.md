# Skill Quality Rubric — Pre-Ship Gate

Binary pass/fail. Must pass 5/5 before the skill ships.

| # | Criterion | Pass | Fail |
|---|-----------|------|------|
| 1 | **Triggers correctly** | Fires on relevant prompts, stays silent on near-misses. Verified with should-trigger + should-NOT-trigger eval set. | False positives, obvious misses, or untested. |
| 2 | **Lean context** | L1 description under 150 words. L2 SKILL.md body under 500 lines. Heavy data in `references/`. Scripts in `scripts/`. | Monolithic body, inlined schemas, everything loaded at trigger time. |
| 3 | **Grounded** | Built from a successful manual walkthrough. Includes input→output examples from real runs. | Theoretical, no tested workflow, abstract rules only. |
| 4 | **Explains WHY** | Instructions carry reasoning the model can generalize from. Rules explain the constraint they enforce. | Rigid ALL-CAPS MUSTs without rationale; brittle compliance. |
| 5 | **Handles failure** | Explicit error paths, diagnose-before-retry, bounded attempts, clear user-visible error output. | Silent failures, identical retries, infinite loops, no recovery path. |

## How to run the rubric

For each criterion, write a one-line verdict + evidence. If fail, fix before proceeding. Example:

```
1. Triggers correctly — PASS. 18/20 eval queries matched expected outcome (9 should-trigger hit, 9 near-miss avoided).
2. Lean context — FAIL. SKILL.md is 612 lines; move the schema appendix to references/schemas.md.
3. Grounded — PASS. Walked through the Q4 report workflow end-to-end on 2026-04-13, output saved.
4. Explains WHY — PARTIAL. "ALWAYS use ISO 8601" appears once. Rewrite as "Format dates as ISO 8601 because downstream APIs reject other formats."
5. Handles failure — PASS. Error handling section covers schema mismatch + conversion retry + user-facing diagnostic.
```

A partial pass is a fail. Fix and re-run.
