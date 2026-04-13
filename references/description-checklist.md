# Description Optimization Checklist

The description field is the only L1 trigger mechanism. Every skill ships or fails on it. Before finalising, verify:

- [ ] **WHAT** — names the capability concretely (not "helps with X")
- [ ] **WHEN to trigger** — lists contexts, phrases, file types, verbs users actually type
- [ ] **WHEN NOT to trigger** — negative boundaries vs adjacent skills ("do NOT use for…")
- [ ] **Concrete keywords** — file extensions (`.csv`, `.docx`), casual phrasing ("make a deck"), verbs ("fix", "build")
- [ ] **Under 150 words** — this sits in context every turn
- [ ] **Pushy** — errs toward broader activation; Claude undertriggers by default
- [ ] **No ambiguous overlap** — distinguishable from existing skills in the user's library
- [ ] **Casual phrasings included** — not only formal ones

## Good vs bad

**Bad:** `"Helps with documents"`

**Good:**
```yaml
description: >
  Create, read, edit, or manipulate Word documents (.docx files).
  Triggers on: 'Word doc', '.docx', requests for reports/memos/letters
  with formatting (TOC, headings, page numbers, letterheads).
  Also use when extracting content from .docx files, performing
  find-and-replace, or converting content into polished Word documents.
  Do NOT use for PDFs, spreadsheets, or Google Docs.
```

## Why this matters

Skill descriptions cost ~53 tokens and sit in context permanently. The full SKILL.md costs ~944 tokens and only loads when triggered. A bad description means the skill never fires, or fires on the wrong prompts — both waste the work that went into the body.

Run this checklist before any skill ships. Run it again after `scripts/run_loop.py` (from `skill-creator`) produces a `best_description` — the optimizer is good but not perfect, and a human-verified description beats an optimizer-verified one.
