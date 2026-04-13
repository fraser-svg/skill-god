<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/trident-emblem_1f531.png" width="120" />
</p>

<h1 align="center">skill-god</h1>

<p align="center">
  <strong>skills that actually fire. every time.</strong>
</p>

<p align="center">
  <a href="https://github.com/fraser-svg/skill-god/stargazers"><img src="https://img.shields.io/github/stars/fraser-svg/skill-god?style=flat&color=yellow" alt="Stars"></a>
  <a href="https://github.com/fraser-svg/skill-god/commits/master"><img src="https://img.shields.io/github/last-commit/fraser-svg/skill-god?style=flat" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/fraser-svg/skill-god?style=flat" alt="License"></a>
  <a href="https://claude.com/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-8b5cf6" alt="Claude Code"></a>
</p>

<p align="center">
  <a href="#before--after">Before/After</a> •
  <a href="#install">Install</a> •
  <a href="#what-you-get">What You Get</a> •
  <a href="#examples">Examples</a> •
  <a href="#philosophy">Philosophy</a> •
  <a href="#faq">FAQ</a>
</p>

---

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) meta-skill that writes production-grade skills with quality gates Anthropic's `skill-creator` doesn't ship by default — grounding gate, 5-criterion rubric, security pre-scan, anti-pattern catalogue. The skill-writing arm of [**commander**](https://github.com/fraser-svg/commander). Its other half.

Based on the painful observation that everyone building Claude Code skills ships the same broken artifact — description full of hedges, body full of all-caps MUSTs, 40% of the rules teaching the model what JSON is. The skill never fires, and when it does, it reads like a compliance doc. So we made the gates non-negotiable.

## Before / After

<table>
<tr>
<td width="50%">

### 🛠️ Hand-rolled skill

> "Okay, `description` first. I'll write three sentences about what it does. Body is 400 lines of `IMPORTANT: ALWAYS DO X`. Why isn't it triggering on `fix this bug`? Let me add more keywords. Still not firing. Let me add MORE keywords. Now it fires on everything."

</td>
<td width="50%">

### 🔱 skill-god

> "make a skill that debugs failing tests"

**Pushy description, 10 trigger phrases, 5 negative triggers, 10/10 eval pass, 120-line body — shipped.**

</td>
</tr>
<tr>
<td>

### 🛠️ Hand-rolled audit

> "This skill isn't firing. Let me read it. 300 lines. Half of it is telling Claude how markdown headers work. The critical rule is buried on line 187. I'll rewrite it... where do I even start?"

</td>
<td>

### 🔱 skill-god

> "audit this skill and fix triggering"

**Anti-pattern catalogue scan, grounding-gate rewrite, pre-trained rules deleted, critical rule moved to front, re-evaled, shipped.**

</td>
</tr>
</table>

**Same skill. Gates enforced. Slop filtered at write-time, not at use-time.**

```
┌─────────────────────────────────────────┐
│  TRIGGER RELIABILITY  ████████  10/10   │
│  GROUNDING GATE       ████████  every rule │
│  SECURITY PRE-SCAN    ████████  every mode │
│  RUBRIC GATES         ████████  5/5 pass │
│  DRIFT CHECK          ████████  CI-able │
└─────────────────────────────────────────┘
```

- **Grounding gate on every rule** — if a blank-prompt Sonnet 4.6 would do it right >70% of the time, the rule gets cut. No more teaching Claude pre-trained behavior.
- **5-criterion quality rubric** — runs at Phase 2 pre-test and Phase 6 pre-ship. 5/5 to proceed. No partial credit.
- **Security pre-scan in every execution mode** — even agent-mode (which skips later phases). Secret exfiltration, network sinks, sandbox bypass caught before drafting.
- **Anti-pattern catalogue** — monolithic body, all-caps MUSTs, identical-retry, buried critical rules. Phase 4 forces *generalized* fixes, not spot patches.
- **Pointer drift check** — `scripts/verify_pointers.sh` greps upstream `skill-creator/SKILL.md`. Breaks loud when Anthropic renames a section.

## Install

```bash
# 1. Install skill-creator (Anthropic, ships separately with Claude Code)
ls ~/.claude/skills/skill-creator/SKILL.md

# 2. Clone skill-god:
git clone https://github.com/fraser-svg/skill-god.git ~/.claude/skills/skill-god

# 3. Verify upstream pointers still resolve:
bash ~/.claude/skills/skill-god/scripts/verify_pointers.sh

# 4. Clone commander if you want the full team-building pair:
git clone https://github.com/fraser-svg/commander.git ~/.claude/skills/commander
```

Open any project in Claude Code and say *"make a skill for..."*. That it.

> [!NOTE]
> Skill-god is a thin opinionated jacket over Anthropic's [`skill-creator`](https://github.com/anthropics/skills). It delegates eval, grading, viewer, optimizer, and packaging to the upstream. Install skill-creator first or skill-god refuses to run. No silent fallback.

> [!IMPORTANT]
> [`commander`](https://github.com/fraser-svg/commander) delegates **all** skill-writing to skill-god. Commander refuses to run without it. They are one toolkit: commander builds agent teams, skill-god writes the skills those agents use. Install both.

## What You Get

| Feature | skill-god |
|---------|:---------:|
| 10 commandments loaded as L1 working memory | Y |
| 5-criterion quality rubric (binary pass/fail) | Y |
| Grounding gate on every generated rule | Y |
| Security pre-scan runs in every execution mode | Y |
| Anti-pattern catalogue with named fixes | Y |
| Pushy description style with negative triggers | Y |
| Pointer drift check against upstream `skill-creator` | Y |
| Harness-mode file-based handoff (`_workspace/skill-god/HANDOFF.md`) | Y |
| Worked example Phase 0→6 inlined in L2 | Y |
| Delegates mechanics to Anthropic's `skill-creator` | Y |

## Examples

One sentence in, shippable skill out.

```
"make a skill for debugging failing tests"
"audit this skill and tell me why it's not triggering"
"fix skill triggering for my content-calendar skill"
"optimize this description — it fires on everything"
"codify the workflow I just ran end-to-end"
"build the skill commander asked for"
```

## The 7 phases

```
Grounding → Draft → Rubric → Eval → Package → Ship → Drift-check
```

Grounding gate first. Rubric gate before eval. Eval gate before ship. Drift check after every `skill-creator` update. Full protocol in [`SKILL.md`](./SKILL.md) — every phase is load-bearing and they're all there for a reason.

## Philosophy

Skill-god has opinions and enforces them at write-time, not at use-time.

**A skill that doesn't fire is a skill that doesn't exist.** Descriptions are triggers, not documentation. Write them pushy, with negative triggers, or don't ship.

**Every rule earns its place.** Same grounding gate [commander](https://github.com/fraser-svg/commander) uses on agents. If Claude already does it right, writing the rule wastes tokens and buries the rules that matter.

**Security is only security if it's code.** Prose instructions that say *"don't exfiltrate secrets"* are theatre. The pre-scan is a scan, not a suggestion. Runs in agent-mode too.

**Composition over god-objects.** Skill-god writes skills. Commander writes teams. Anthropic's `skill-creator` runs the eval/grading/packaging machinery. Nobody reaches across. Taste in what *not* to build is the whole job.

## FAQ

**Do I need `skill-creator`?** Yes. Skill-god delegates Phases 3–6 to it. Won't run without it.

**Do I need commander?** No — skill-god works standalone. But if you install commander, commander *will* require skill-god. They're one pair.

**Will this work on `claude-3-5-sonnet`?** No. Skill-god targets the Claude 4.5/4.6 family. Grounding gate assumes pre-trained behavior at 4.6-level fluency.

**Does it work outside Claude Code?** Claude Code only (with subagents). On Claude.ai and Cowork, use `skill-creator` directly — it has platform-specific branches. Skill-god doesn't.

**Can I override the rubric?** No. 5/5 is 5/5. Soften a gate and you get the same broken skills everyone else ships.

**Is the pointer drift check magic?** No. It greps upstream section names. When Anthropic renames something, it fails loud. You update the map and move on. Honest tool.

## Relationship to commander

Commander is the team-builder. Skill-god is the skill-writer. At commander Phase 4, the orchestrator writes a skill spec JSON to `_workspace/<run-id>/skill-god/inbox/<skill-name>.json`. Skill-god reads it, runs the full pipeline (grounding → draft → rubric → eval → package → ship), writes the result to `.claude/skills/<harness-name>/<skill-name>/`, and drops a handoff at `_workspace/<run-id>/skill-god/HANDOFF_<skill-name>.md`. Commander resumes. Neither reaches across.

Install both. They're one toolkit.

## Contributing

Read [`SKILL.md`](./SKILL.md) first. Opinions are load-bearing — PRs that soften the gates get pushback, PRs that sharpen them get merged fast.

## License

MIT. See [LICENSE](./LICENSE).

---

<p align="center">
  <sub>Built with <a href="https://claude.com/claude-code">Claude Code</a>. Sibling project: <a href="https://github.com/fraser-svg/commander">commander</a>. Ship a wild skill with skill-god? Open an issue — I want to see it.</sub>
</p>
