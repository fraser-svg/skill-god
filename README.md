# skill-god

**The skill-writing arm of `/harness`.** Production-grade quality gates for creating Claude Code skills, layered over Anthropic's `skill-creator` machinery.

`/harness` Phase 4 always delegates here. Use it standalone too — same gates apply.

## What it does

Skill-god is an opinionated wrapper. It does **not** reimplement the eval/grading/viewer/optimizer/packaging machinery (that's `skill-creator`'s job). It adds:

- **10 commandments** loaded as L1 working memory before drafting
- **5-criterion quality rubric** inlined in L2 — runs at Phase 2 (pre-test) and Phase 6 (pre-ship), 5/5 to proceed
- **Grounding gate** — refuses to codify workflows the user has never run end-to-end
- **Security pre-scan** — active scan for secret exfiltration, network sinks, sandbox bypass; refuses or rewrites in every mode (including agent-mode that skips later phases)
- **Anti-pattern catalogue** — Phase 4 cross-checks failures against named patterns (monolithic body, all-caps MUSTs, identical-retry, etc) and forces *generalized* fixes
- **Worked example** — full Phase 0→6 walkthrough in L2 so a model can pattern-match
- **Pointer drift verification** — `scripts/verify_pointers.sh` greps upstream `skill-creator/SKILL.md` to confirm the section names skill-god references still exist
- **Harness mode** — file-based handoff via `_workspace/skill-god/HANDOFF.md` for use inside `TeamCreate` agent teams that can't spawn nested subagents

## ⚠️ Hard dependencies

| Dependency | Required for | Verify |
|---|---|---|
| `~/.claude/skills/skill-creator/SKILL.md` | Phases 3, 4, 5, 6 (eval/grading/optimizer/packaging) | `ls ~/.claude/skills/skill-creator/SKILL.md` |
| `~/.claude/skills/harness/SKILL.md` | Optional — only when invoked from `/harness` | Skill-god still works standalone without it |

**Install skill-creator first.** Skill-god alone is incomplete — its middle phases reference paths that won't exist.

## Platform support

| Platform | Status |
|---|---|
| Claude Code (with subagents) | ✅ full workflow |
| Claude.ai | ❌ use `skill-creator` directly (it has a Claude.ai branch) |
| Cowork | ❌ use `skill-creator` directly (it has a Cowork branch) |

## Install

```bash
# 1. Install skill-creator (Anthropic, ships separately)
# 2. Clone skill-god:
git clone https://github.com/fraser-svg/skill-god.git ~/.claude/skills/skill-god

# 3. Verify both present:
ls ~/.claude/skills/skill-creator/SKILL.md ~/.claude/skills/skill-god/SKILL.md

# 4. Verify upstream section pointers still resolve (run after every skill-creator update):
bash ~/.claude/skills/skill-god/scripts/verify_pointers.sh
```

Claude Code auto-discovers both on next session start.

## Use

In Claude Code, just say:

- "make a skill for X"
- "audit this skill"
- "fix skill triggering for Y"
- `/skill-god`

In `/harness` Phase 4, the orchestrator calls `Skill({skill: "skill-god"})` for every new agent's skill. Inside a harness team, copy `assets/skill-architect-agent.md` to `.claude/agents/skill-architect.md` and the team can write skills via `SendMessage`.

## What's inside

- `SKILL.md` — main entry. Inlines commandments, rubric, security clause, and a compressed worked example.
- `references/skill-creation-guide.md` — definitive deep-dive (anti-patterns, writing style, error recovery)
- `references/quality-rubric.md` — full rubric template
- `references/description-checklist.md` — trigger-phrase checklist for Phase 1
- `references/harness-mode.md` — execution-mode matrix and conventions for harness teams (loaded only in harness mode)
- `scripts/verify_pointers.sh` — drift check against upstream `skill-creator/SKILL.md`
- `assets/skill-architect-agent.md` — drop-in subagent template for harness teams

## When to use which

| You are… | Use |
|---|---|
| Inside `/harness` Phase 4 | **skill-god** (always — `/harness` enforces it) |
| Casual Claude Code user, want gates + rubric + grounding | **skill-god** |
| Casual one-shot, no gates, on Claude Code | **skill-creator** directly |
| Claude.ai or Cowork user | **skill-creator** directly |

## Maintenance

Run the drift check after every skill-creator update:

```bash
bash ~/.claude/skills/skill-god/scripts/verify_pointers.sh
```

If it reports `MISS`, update the `Delegated mechanics` table in `SKILL.md` to match the new upstream heading names.

## License

MIT
