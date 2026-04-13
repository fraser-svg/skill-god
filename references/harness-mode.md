# Harness Mode

Load this file when skill-god is invoked from `/harness` (revfactory/harness) or from inside a harness agent team. Skip it otherwise.

## Execution modes (by invoker)

| Mode | Invoked by | How to load this skill | Phase 3 eval machinery | Workspace |
|------|-----------|-----------------------|------------------------|-----------|
| **Main session** | User in Claude Code | `Skill` tool (auto-triggered) | Full — spawn with-skill + baseline subagents per `skill-creator/SKILL.md` | `<skill>-workspace/iteration-N/` |
| **Harness orchestrator** | `/harness` Phase 4 (generating a skill for a new agent) | Main Claude calls `Skill({skill: "skill-god"})` inside harness Phase 4 | Full (same as main) | Same as main |
| **Harness agent / team member** | A member inside a `TeamCreate` team that needs to create or improve a skill mid-task | `Read /Users/foxy/.claude/skills/skill-god/SKILL.md` as the first tool call of the task | **Skip** — no nested subagents; hand the skill to the orchestrator to test in the main session | `<project>/_workspace/skill-god/` (file-based, per harness convention) |

## Why agent mode skips Phase 3

Harness agents are themselves subagents. Spawning more subagents inside them for eval runs would multiply tokens and hit harness limits. Instead:

1. The agent completes Phases 0, 1, 2, 4 (as edits), 5 (manual checklist only), and 6 (rubric only) on disk.
2. The agent writes a `_workspace/skill-god/HANDOFF.md` listing: skill path, rubric verdict, open questions, recommended test prompts.
3. The agent reports "skill drafted, ready for eval" via `SendMessage` to the orchestrator (or returns via `Agent` result).
4. The orchestrator (main session) picks up the handoff and runs Phase 3 + 5 with full machinery.

This mirrors the harness Phase 7 evolution pattern: file-based handoff, orchestrator does eval. See `~/.claude/skills/harness/SKILL.md` Phase 5-1 file-based data passing.

## Harness conventions

When invoked by or inside the `/harness` system, skill-god respects these rules:

- **Agent definitions are harness's job.** Skill-god never writes files under `.claude/agents/`. If Phase 0 reveals the user wanted an agent + skill pair, hand agent creation back to `/harness` and wait for the agent definition before drafting the skill.
- **Skill directory layout** matches harness `references/skill-writing-guide.md`: `SKILL.md` + `references/` + optional `scripts/`. No `assets/` unless the skill outputs files.
- **1 skill ↔ 1 workflow** (harness skill-writing-guide §4-5). If the user describes two workflows, draft two skills and tell `/harness` about the second.
- **Pushy description style** (harness skill-writing-guide §4-2) aligns with skill-god commandment #2.
- **500-line body cap** (harness skill-writing-guide §4-4) aligns with skill-god commandment #1.
- **Data schema standards** for skills that exchange structured data with other harness agents: follow `~/.claude/skills/harness/references/skill-writing-guide.md`.
- **QA agents** building skills that validate other agents' output: read `~/.claude/skills/harness/references/qa-agent-guide.md` before drafting — QA skills have extra constraints (incremental runs, boundary-crossing verification).
- **Team examples** for prior art: `~/.claude/skills/harness/references/team-examples.md`.
- **CLAUDE.md pointer:** if this is the first skill in a new harness, remind the orchestrator to add a 변경 이력 row per harness SKILL.md Phase 5-4 template. Do not write CLAUDE.md yourself.

## Drop-in agent for harness teams

When `/harness` designs a team that will create skills mid-session (e.g., a meta-development team), copy the agent template from `assets/skill-architect-agent.md` into the target project's `.claude/agents/skill-architect.md`. That agent definition:

- Reads skill-god's SKILL.md on startup (agent mode).
- Accepts skill-drafting tasks from the team lead via `SendMessage`.
- Writes drafts to `_workspace/skill-god/` for orchestrator handoff.
- Does not spawn subagents.
