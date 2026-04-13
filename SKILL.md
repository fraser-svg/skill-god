---
name: skill-god
description: >
  Create, edit, refine, or audit Claude skills with production-grade quality
  gates, tailored for the revfactory/harness agent-team system. Use whenever
  the user says "make a skill", "create skill", "write a skill", "new skill",
  "build a skill", "improve this skill", "fix skill triggering", "optimize
  skill description", "skill isn't firing", "codify this workflow", or
  touches any SKILL.md or .claude/skills/ path. Also use when /harness
  (revfactory/harness Phase 4) needs to generate a skill for a newly defined
  agent — skill-god is the opinionated skill-writer that harness delegates
  to. Combines skill-creator's draft/test/iterate/optimize/package workflow
  with the definitive skill-creation-guide (progressive disclosure L1/L2/L3,
  pushy descriptions, explain-WHY writing, bundled scripts, quality rubric,
  10 commandments) AND harness conventions (agent teams, TeamCreate,
  SendMessage, file-based coordination via _workspace/). Works from the main
  session (Skill tool) and from inside harness agent teams (Read tool on
  ~/.claude/skills/skill-god/SKILL.md). Enforces a 5-criterion pre-ship gate
  and a manual walkthrough before any skill is codified. Use INSTEAD of
  skill-creator as the default entry point; compose WITH /harness rather
  than replacing it. Do NOT use for editing files in .claude/agents/ (that
  is harness's job — skill-god only writes the skill, not the agent), or
  for generating skills from a doc URL (use firecrawl:skill-gen).
---

# Skill-God

The opinionated meta-skill for building skills that actually work. Wraps `~/.claude/skills/skill-creator/` (machinery: evals, viewer, optimizer, packaging) with the enforcement gates from `references/skill-creation-guide.md` (principles: progressive disclosure, pushy descriptions, explain-why, anti-patterns, quality rubric).

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

## Execution modes

Skill-god runs in three modes depending on who invokes it. The phases are the same; the machinery changes.

| Mode | Invoked by | How to load this skill | Phase 3 eval machinery | Workspace |
|------|-----------|-----------------------|------------------------|-----------|
| **Main session** | User in Claude Code | `Skill` tool (auto-triggered) | Full — spawn with-skill + baseline subagents per `skill-creator/SKILL.md` | `<skill>-workspace/iteration-N/` |
| **Harness orchestrator** | `/harness` Phase 4 (generating a skill for a new agent) | Main Claude calls `Skill({skill: "skill-god"})` inside harness Phase 4 | Full (same as main) | Same as main |
| **Harness agent / team member** | A member inside a `TeamCreate` team that needs to create or improve a skill mid-task | `Read /Users/foxy/.claude/skills/skill-god/SKILL.md` as the first tool call of the task | **Skip** — no nested subagents; hand the skill to the orchestrator to test in the main session | `<project>/_workspace/skill-god/` (file-based, per harness convention) |

### Why agent mode skips Phase 3

Harness agents are themselves subagents. Spawning more subagents inside them for eval runs would multiply tokens and hit harness limits. Instead:

1. The agent completes Phases 0, 1, 2, 4 (as edits), 5 (manual checklist only), and 6 (rubric only) on disk.
2. The agent writes a `_workspace/skill-god/HANDOFF.md` listing: skill path, rubric verdict, open questions, recommended test prompts.
3. The agent reports "skill drafted, ready for eval" via `SendMessage` to the orchestrator (or returns via `Agent` result).
4. The orchestrator (main session) picks up the handoff and runs Phase 3 + 5 with full machinery.

This mirrors the harness Phase 7 "진화" (evolution) pattern: file-based handoff, orchestrator does eval. See `~/.claude/skills/harness/SKILL.md` Phase 5-1 "파일 기반" data passing.

## Harness integration

When invoked by or inside the `/harness` system (revfactory/harness), skill-god respects these conventions:

- **Agent definitions are harness's job.** Skill-god never writes files under `.claude/agents/`. If Phase 0 reveals the user wanted an agent + skill pair, hand agent creation back to `/harness` and wait for the agent definition before drafting the skill.
- **Skill directory layout** matches harness `references/skill-writing-guide.md`: `SKILL.md` + `references/` + optional `scripts/`. No `assets/` unless the skill outputs files.
- **1 skill ↔ 1 workflow** (harness skill-writing-guide §4-5). If the user describes two workflows, draft two skills and tell `/harness` about the second.
- **Pushy description style** (harness skill-writing-guide §4-2) aligns with commandment #2 here.
- **500-line body cap** (harness skill-writing-guide §4-4) aligns with commandment #1.
- **Data schema standards** for skills that exchange structured data with other harness agents: follow `~/.claude/skills/harness/references/skill-writing-guide.md`.
- **QA agents** building skills that validate other agents' output: read `~/.claude/skills/harness/references/qa-agent-guide.md` before drafting — QA skills have extra constraints (incremental runs, boundary-crossing verification).
- **Team examples** for prior art: `~/.claude/skills/harness/references/team-examples.md`.
- **CLAUDE.md pointer:** if this is the first skill in a new harness, remind the orchestrator to add a `변경 이력` row per harness SKILL.md Phase 5-4 template. Do not write CLAUDE.md yourself.

## Drop-in agent for harness teams

When `/harness` designs a team that will create skills mid-session (e.g., a meta-development team), copy the agent template from `assets/skill-architect-agent.md` into the target project's `.claude/agents/skill-architect.md`. That agent definition:

- Reads skill-god's SKILL.md on startup (agent mode).
- Accepts skill-drafting tasks from the team lead via `SendMessage`.
- Writes drafts to `_workspace/skill-god/` for orchestrator handoff.
- Does not spawn subagents.

## Delegated mechanics

Skill-god does not reimplement skill-creator. For the heavy workflow machinery, follow the sections of `~/.claude/skills/skill-creator/SKILL.md` cited below. Skill-god adds gates around those sections — it does not replace them.

| Machinery | Owner file | Section |
|-----------|------------|---------|
| Spawning with-skill + baseline eval runs | `~/.claude/skills/skill-creator/SKILL.md` | "Running and evaluating test cases" |
| Grading & aggregating benchmark | same | Step 4 |
| Launching eval viewer | same | Step 4 |
| Reading feedback | same | Step 5 |
| Iteration loop | same | "Improving the skill" |
| Description optimizer | same | "Description Optimization" + `scripts/run_loop.py` |
| Packaging | same | "Package and Present" |

## Phase 0 — Intent capture + grounding gate

Before anything else, establish what the skill is for and whether a grounded workflow exists.

Ask the user (adapt to their technical level — see `skill-creator/SKILL.md` "Communicating with the user"):

1. What should this skill enable Claude to do?
2. When should it trigger? (phrases, file types, contexts)
3. What's the expected output format?
4. **Grounding gate (commandment #3):** has this workflow been run successfully at least once? If no, stop here and walk through it manually in conversation. Label outputs correct/incorrect as they appear. Only codify after one end-to-end success.

Skip the grounding gate only if the user explicitly says "vibe mode" or the skill is extremely trivial (e.g., a one-line style rule). Default is: walkthrough first.

## Phase 1 — Draft with gates

Draft the skill at `<target-path>/SKILL.md` plus any `references/`, `scripts/`, `assets/` the design calls for.

**Frontmatter:**
- Open `references/description-checklist.md` and fill in each item as you write the description.
- Aim for the pushy style modelled by `skill-god`'s own description above.
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

Before spawning any evals, run the 5-criterion rubric from `references/quality-rubric.md` against the draft. Write one-line verdicts inline (e.g. in a scratch note or directly to the user). Must pass 5/5 before proceeding. Common failures and fixes:

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

Final rubric pass using `references/quality-rubric.md`. Must still be 5/5 after iteration. Then delegate packaging to `~/.claude/skills/skill-creator/SKILL.md` "Package and Present".

Announce to the user: where the skill lives, the trigger score from Phase 5, the path to the `.skill` file if one was produced, and any known gaps you chose to defer.

## Error recovery (for this skill itself)

If a phase fails:

1. Identify which commandment or rubric criterion was violated.
2. Return to the earliest phase that produces the violated artifact.
3. Do not retry the same operation identically — diagnose first, change one thing, re-run.

If a delegated skill-creator step fails (script error, missing file, viewer won't launch), read the error, fix the specific issue, and resume — do not abandon the whole workflow.

## Why skill-god exists (and why it doesn't replace skill-creator)

Skill-creator ships with Anthropic and owns the mechanism: spawning subagents, running evals, grading, viewing, optimizing descriptions, packaging. That machinery is sound. Editing it would fork from upstream and cause merge pain.

Skill-god owns the opinion: which principles from the definitive guide must hold, which gates must pass, which anti-patterns must be caught. It delegates to skill-creator for execution and enforces quality on top.

One more time, the core loop under skill-god's gates:

1. **Phase 0** — Intent + grounding gate. Manual walkthrough if not yet run.
2. **Phase 1** — Draft with description checklist and guide principles.
3. **Phase 2** — 5-criterion rubric pre-test gate.
4. **Phase 3** — Delegate eval runs to skill-creator; enforce realistic prompts.
5. **Phase 4** — Iterate, cross-checking against anti-patterns.
6. **Phase 5** — Manual description pass → optimizer → manual re-check.
7. **Phase 6** — Final rubric + packaging.

Remember: progressive disclosure. Description is king. Manual first. Explain why. Examples over rules. Failures are features.
