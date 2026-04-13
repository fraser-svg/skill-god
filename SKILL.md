---
name: skill-god
description: >
  Create, edit, refine, or audit Claude skills with production-grade quality
  gates. Use whenever the user says "make a skill", "create skill", "write a
  skill", "new skill", "build a skill", "improve this skill", "fix skill
  triggering", "optimize skill description", "skill isn't firing", "codify
  this workflow", or touches any SKILL.md or .claude/skills/ path. Wraps
  Anthropic's skill-creator (machinery: evals, viewer, optimizer, packaging)
  with enforcement gates: progressive disclosure L1/L2/L3, pushy descriptions,
  explain-WHY writing, bundled scripts, 5-criterion quality rubric, 10
  commandments, anti-pattern catalogue, grounding gate before codification.
  Use INSTEAD of skill-creator as the default entry point for Claude Code
  users — composes WITH it, never replaces it. Also handles the harness
  agent-team mode when invoked from /harness Phase 4 (see
  references/harness-mode.md). Do NOT use for editing files in
  .claude/agents/, or for generating skills from a doc URL (use
  firecrawl:skill-gen instead). Claude Code only — no Claude.ai or Cowork
  branch yet.
---

# Skill-God

The opinionated meta-skill for building skills that actually work. Wraps `~/.claude/skills/skill-creator/` (machinery: evals, viewer, optimizer, packaging) with the enforcement gates from `references/skill-creation-guide.md` (principles: progressive disclosure, pushy descriptions, explain-why, anti-patterns, quality rubric).

## Hard dependency

Skill-god delegates Phases 3, 4, 5, 6 to Anthropic's `skill-creator`. **It cannot run without it.** Before invoking skill-god, verify:

```bash
ls ~/.claude/skills/skill-creator/SKILL.md
```

If missing, install it first (Anthropic's skill-creator skill ships separately). Skill-god is a thin opinionated jacket over that machinery — it does not reimplement spawning, grading, viewer, or packaging.

## Platform compatibility

- ✅ **Claude Code (with subagents)** — full workflow.
- ⚠️ **Claude.ai / Cowork** — not yet branched. Use `~/.claude/skills/skill-creator/SKILL.md` directly for those environments; it has explicit Claude.ai and Cowork sections.

## Principle of Lack of Surprise (security)

Skills must not contain malware, exploit code, credential harvesters, or content that could compromise system security. A skill's contents should not surprise the user given its stated intent. Refuse requests to create:

- Skills that exfiltrate secrets, credentials, SSH keys, tokens, or browser data.
- Skills designed to facilitate unauthorized access, privilege escalation, or lateral movement.
- Skills that deliberately mislabel their purpose to evade user review.
- Skills that disable safety checks, security tooling, or audit logging.

Roleplay or persona skills (e.g., "respond as a grumpy senior engineer") are fine. Defensive security skills, CTF training, and authorized pentest tooling are fine when the context is clear.

This rule holds in **all execution modes**, including agent mode (which skips other phases). Do not delegate this check to a phase the agent might skip.

## The 10 Commandments

Load these into working memory before drafting anything.

1. **Progressive disclosure.** L1 frontmatter (~100 words, always in context) → L2 body (<500 lines, loaded on trigger) → L3 references/scripts (unlimited, loaded on demand). Never dump everything into L2.
2. **Description is king.** Pushy, specific, under 150 words. State WHAT + WHEN + WHEN NOT. Claude undertriggers by default — err broader.
3. **Manual first.** Walk through the workflow live and succeed at least once before codifying anything. Theoretical skills produce confident slop.
4. **Explain WHY.** Reasoning beats rigid rules. Models generalize from understanding. If you catch yourself writing ALWAYS/NEVER/MUST in caps, reframe.
5. **Don't teach what's known.** Only proprietary/domain knowledge belongs. React, Python, SQL — the model already has them.
6. **Positive instructions.** Say what TO do. Negatives get inverted by token prediction.
7. **Include examples.** Input→output pairs. Concrete, not abstract.
8. **Bundle scripts.** Repeated deterministic work goes in `scripts/`, not instructions. Saves tokens, prevents drift.
9. **Test with real prompts.** Casual, messy, realistic — "ok so my boss sent me this xlsx (Q4 sales final FINAL v2.xlsx)". Not synthetic happy paths.
10. **Failures are features.** Every diagnosed error = permanent improvement. Ratchet up.

Full guide: `references/skill-creation-guide.md`. Read it when any phase is unclear.

## The 5-criterion rubric (inline)

Run this gate at Phase 2 (pre-test) and Phase 6 (pre-ship). Binary pass/fail. 5/5 to proceed.

1. **Triggers correctly** — fires on relevant prompts, stays silent on near-misses. Verified with should-trigger + should-NOT-trigger eval set.
2. **Lean context** — L1 description <150 words; L2 body <500 lines; heavy data in `references/`; deterministic work in `scripts/`.
3. **Grounded** — built from a successful manual walkthrough; includes input→output examples from real runs.
4. **Explains WHY** — instructions carry reasoning the model can generalize from; no rigid all-caps MUSTs without rationale.
5. **Handles failure** — explicit error paths, diagnose-before-retry, bounded attempts, clear user-visible error output.

Partial pass = fail. Write a one-line verdict per criterion with evidence. Full template: `references/quality-rubric.md`.

## Delegated mechanics

Skill-god does not reimplement skill-creator. For workflow machinery, follow these sections of `~/.claude/skills/skill-creator/SKILL.md`:

| Machinery | Section in skill-creator/SKILL.md |
|-----------|-----------------------------------|
| Spawning with-skill + baseline eval runs | "Running and evaluating test cases" |
| Grading & aggregating benchmark | Step 4 |
| Launching eval viewer | Step 4 |
| Reading feedback | Step 5 |
| Iteration loop | "Improving the skill" |
| Description optimizer | "Description Optimization" + `scripts/run_loop.py` |
| Packaging | "Package and Present" |

**Drift risk:** these section names are quoted from upstream. If skill-creator is rewritten, re-validate the pointers.

## Phase 0 — Intent capture + grounding gate

Before anything else, establish what the skill is for and whether a grounded workflow exists.

Ask the user (adapt to their technical level — see `skill-creator/SKILL.md` "Communicating with the user"; for non-coders avoid jargon like "assertion" or "JSON schema" without definition):

1. What should this skill enable Claude to do?
2. When should it trigger? (phrases, file types, contexts)
3. What's the expected output format?
4. **Grounding gate (commandment #3):** has this workflow been run successfully at least once? If no, stop here and walk through it manually in conversation. Label outputs correct/incorrect as they appear. Only codify after one end-to-end success.

Skip the grounding gate only if the user explicitly says "vibe mode" or the skill is extremely trivial (e.g., a one-line style rule). Default is: walkthrough first.

## Phase 1 — Draft with gates

Draft the skill at `<target-path>/SKILL.md` plus any `references/`, `scripts/`, `assets/` the design calls for.

**Frontmatter:**
- Open `references/description-checklist.md` and fill in each item as you write the description.
- Aim for the pushy style modelled by skill-god's own description above.
- Verify <150 words before moving on.

**Body (commandments #4, #5, #6, #7):**
- Imperative form. "Extract the data" not "You should extract the data".
- Lead each non-obvious instruction with the reasoning. Example: *"Format dates as ISO 8601 because downstream APIs reject other formats"* instead of *"ALWAYS use ISO 8601"*.
- Positive framing. If you catch a negative, flip it.
- At least one input→output example per major operation.
- Cap body at 500 lines. If it grows past that, split into `references/` by variant (domain, framework, language) and leave pointers.

**Resources (commandment #8):**
- If any repeated work looks deterministic (template fill, schema validation, file transform), write it as a script under `scripts/` and reference by path.
- Large schemas, API docs, decision trees → `references/*.md`. Add a table of contents for files over 300 lines.

## Phase 2 — Pre-test quality gate

Run the 5-criterion rubric (above) against the draft before spawning any evals. Write one-line verdicts. Must pass 5/5 before proceeding. Common failures and fixes:

- *Lean context fail:* body over 500 lines → move sections to `references/`.
- *Explains WHY fail:* ALL-CAPS MUSTs remain → rewrite with reasoning.
- *Grounded fail:* no real walkthrough → return to Phase 0.
- *Handles failure fail:* no error-recovery section → add one; see guide §8 "Error Recovery in Skills".

This gate is the anti-slop checkpoint. Running evals on a skill that fails the rubric wastes tokens.

## Phase 3 — Test (delegate)

Follow `~/.claude/skills/skill-creator/SKILL.md` "Running and evaluating test cases" verbatim for the spawning mechanics (with-skill + baseline subagents in the same turn, workspace layout, timing capture, grading, benchmark aggregation, viewer launch).

**Skill-god adds one constraint:** test prompts must be messy and realistic (commandment #9). Anchor example:

> "ok so my boss sent me this xlsx (Q4 sales final FINAL v2.xlsx) and she wants profit margin as a percentage. revenue is col C, costs col D i think"

Not:

> "Format this data"

If the test set reads like synthetic happy paths, reject it and rewrite before spawning runs.

## Phase 4 — Iterate (delegate + anti-pattern cross-check)

Follow `~/.claude/skills/skill-creator/SKILL.md` "Improving the skill" for the iteration loop.

**Skill-god adds:** when diagnosing a failure, cross-check against the anti-patterns in `references/skill-creation-guide.md` §7 before editing. The fix usually maps to one of:

- Monolithic body → split into L3.
- Teaching what the model knows → delete.
- ALL-CAPS enforcement → rewrite with reasoning.
- Identical retry on failure → add diagnostic step.
- Stuffing docs → progressive loading with pointers.

Failures are the ratchet (commandment #10). Every diagnosed issue gets fixed *and generalized* — not overfit to the failing example.

## Phase 5 — Description optimization (delegate, with manual pre-pass)

Before running the optimizer, walk the current description through `references/description-checklist.md` manually. Fix obvious gaps. This cheapens the optimizer run by starting from a better seed.

Then follow `~/.claude/skills/skill-creator/SKILL.md` "Description Optimization" to run `scripts/run_loop.py`. After it completes, re-run the checklist on the `best_description` before applying — the optimizer scores against its own eval set, which may not capture your nuances.

## Phase 6 — Ship gate

Final rubric pass (above) against the iterated skill. Must still be 5/5. Then delegate packaging to `~/.claude/skills/skill-creator/SKILL.md` "Package and Present".

Announce to the user: where the skill lives, the trigger score from Phase 5, the path to the `.skill` file if one was produced, and any known gaps you chose to defer.

## Harness mode (when invoked from /harness)

If `/harness` invokes skill-god, or if you are running inside a harness agent team (TeamCreate member), load `references/harness-mode.md`. It covers:

- Execution-mode matrix (main / orchestrator / agent member)
- Why agent mode skips Phase 3 and uses file-based handoff
- Harness directory conventions and `.claude/agents/` boundary
- The drop-in `skill-architect` agent template

Do not load this file in standalone use — it adds harness-specific constraints that don't apply.

## Error recovery (for this skill itself)

If a phase fails:

1. Identify which commandment or rubric criterion was violated.
2. Return to the earliest phase that produces the violated artifact.
3. Do not retry the same operation identically — diagnose first, change one thing, re-run.

If a delegated skill-creator step fails (script error, missing file, viewer won't launch), read the error, fix the specific issue, and resume — do not abandon the whole workflow.

## Why skill-god exists (and why it doesn't replace skill-creator)

Skill-creator ships with Anthropic and owns the mechanism: spawning subagents, running evals, grading, viewing, optimizing descriptions, packaging. That machinery is sound. Editing it would fork from upstream and cause merge pain.

Skill-god owns the opinion: which principles from the definitive guide must hold, which gates must pass, which anti-patterns must be caught. It delegates to skill-creator for execution and enforces quality on top.

Core loop under skill-god's gates:

1. **Phase 0** — Intent + grounding gate. Manual walkthrough if not yet run.
2. **Phase 1** — Draft with description checklist and guide principles.
3. **Phase 2** — 5-criterion rubric pre-test gate.
4. **Phase 3** — Delegate eval runs to skill-creator; enforce realistic prompts.
5. **Phase 4** — Iterate, cross-checking against anti-patterns.
6. **Phase 5** — Manual description pass → optimizer → manual re-check.
7. **Phase 6** — Final rubric + packaging.

Remember: progressive disclosure. Description is king. Manual first. Explain why. Examples over rules. Failures are features.
