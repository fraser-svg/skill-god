# skill-god

Production-grade skill creator for Claude Code. Opinionated workflow for building, editing, auditing, and shipping skills with progressive disclosure (L1/L2/L3), pushy descriptions, bundled scripts, and a 5-criterion pre-ship quality gate.

Harness-aware: composes with `revfactory/harness` agent teams, but works standalone in any Claude Code session.

## Install

Clone into your user-level skills directory:

```bash
git clone https://github.com/fraser-svg/skill-god.git ~/.claude/skills/skill-god
```

Claude Code auto-discovers it on next session start.

## Use

In Claude Code, just say:

- "make a skill for X"
- "audit this skill"
- "fix skill triggering for Y"
- `/skill-god`

The Skill tool will load `SKILL.md` and walk you through the workflow.

## What's inside

- `SKILL.md` — main skill entry point
- `references/skill-creation-guide.md` — definitive guide (10 commandments, progressive disclosure, writing style)
- `references/quality-rubric.md` — 5-criterion pre-ship gate
- `references/description-checklist.md` — trigger-phrase optimization
- `assets/skill-architect-agent.md` — sub-agent prompt for harness integration

## License

MIT
