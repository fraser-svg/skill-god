# skill-god

Production-grade skill creator for Claude Code. Opinionated workflow for building, editing, auditing, and shipping skills with progressive disclosure (L1/L2/L3), pushy descriptions, bundled scripts, an inline 5-criterion quality gate, and an anti-pattern catalogue.

## ⚠️ Hard dependency: skill-creator

skill-god is a **thin opinionated jacket** over Anthropic's `skill-creator`. It does not reimplement spawning, grading, viewer, or packaging — it delegates Phases 3, 4, 5, 6 to skill-creator.

**Install skill-creator first.** Without it, skill-god's middle phases reference paths that don't exist and will fail.

## Platform support

| Platform | Status |
|---|---|
| Claude Code (with subagents) | ✅ full workflow |
| Claude.ai | ❌ not branched — use `skill-creator` directly (it has a Claude.ai section) |
| Cowork | ❌ not branched — use `skill-creator` directly (it has a Cowork section) |

## Install

```bash
# 1. Install skill-creator first (Anthropic, ships separately)
# 2. Then clone skill-god:
git clone https://github.com/fraser-svg/skill-god.git ~/.claude/skills/skill-god
```

Verify both are present:

```bash
ls ~/.claude/skills/skill-creator/SKILL.md ~/.claude/skills/skill-god/SKILL.md
```

Claude Code auto-discovers both on next session start.

## Use

In Claude Code, just say:

- "make a skill for X"
- "audit this skill"
- "fix skill triggering for Y"
- `/skill-god`

The Skill tool loads `SKILL.md` and walks you through Phases 0–6.

## What's inside

- `SKILL.md` — main entry point. Inlines the 10 commandments, the 5-criterion rubric, and the security clause so they survive agent-mode (which skips later phases).
- `references/skill-creation-guide.md` — definitive guide (progressive disclosure deep-dive, anti-pattern catalogue, writing style)
- `references/quality-rubric.md` — full rubric template with worked example
- `references/description-checklist.md` — trigger-phrase optimization
- `references/harness-mode.md` — execution-mode matrix and conventions for use inside `revfactory/harness` agent teams. Loaded only in harness mode.
- `assets/skill-architect-agent.md` — drop-in sub-agent template for harness teams that need to write skills mid-session

## When to use which

| You are… | Use |
|---|---|
| Casual Claude.ai / Cowork user | **skill-creator** directly |
| Claude Code user, casual one-shot | **skill-creator** directly |
| Claude Code user, want gates + rubric | **skill-god** |
| Inside a `/harness` agent team | **skill-god** (only viable option — file-based handoff) |

## License

MIT
