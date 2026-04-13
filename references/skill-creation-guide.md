# The Definitive Skill Creation Guide
## Best Practices for Building Production-Grade AI Agent Skills

**Purpose:** Universal reference for any AI agent to immediately apply when creating, structuring, or refining skills. Grounded in production patterns, not theory.

---

## 1. Skill Architecture

### File Structure

```
skill-name/
├── SKILL.md              # Required. Core instructions
│   ├── YAML frontmatter   # name + description (always in context)
│   └── Markdown body      # Full instructions (loaded on trigger)
└── Bundled Resources/     # Optional
    ├── scripts/           # Deterministic/repetitive tasks
    ├── references/        # Docs loaded as needed
    └── assets/            # Templates, icons, fonts
```

### Three-Level Progressive Disclosure

This is the single most important architectural decision. Never dump everything into active context.

| Level | What | When Loaded | Size Target |
|-------|------|-------------|-------------|
| L1: Frontmatter | name + description | Always (~100 words) | Under 150 words |
| L2: SKILL.md body | Full instructions | On trigger match | Under 500 lines |
| L3: Bundled resources | Heavy data, schemas, scripts | On demand via tool call | Unlimited |

**Why this matters:** Full instruction sets cost ~944 tokens every turn. Skill description costs ~53 tokens. Context windows degrade past 80% utilisation. Keep the agent in the 10-70% optimal zone — sharp, fast, accurate.

**Rule:** Only L1 sits in active context permanently. L2 loads when the skill triggers. L3 loads only when explicitly needed during execution.

---

## 2. Frontmatter: The Trigger Mechanism

The frontmatter is the most critical part of any skill. It determines whether the skill ever fires.

```yaml
---
name: skill-name
description: >
  What this skill does + when to trigger it.
  Include specific contexts, file types, phrases,
  and edge cases that should activate this skill.
---
```

### Description Rules

1. **State WHAT it does AND WHEN to use it.** Both required. "Generates reports" = insufficient. "Generates formatted PDF reports from CSV data. Use when user mentions reports, data summaries, CSV analysis, or asks to visualise tabular data" = correct.

2. **Be pushy, not shy.** Skills undertrigger by default. Err toward broader activation language. Include adjacent phrasings a user might use.

3. **Include negative triggers.** "Do NOT use for Google Sheets, live dashboards, or API integrations" prevents false matches against competing skills.

4. **Use concrete keywords.** Match the language real users actually type: file extensions (.csv, .xlsx), casual phrasing ("make a deck"), action verbs ("fix", "clean", "build").

5. **Keep under 150 words.** This sits in context on every single turn. Token cost is real.

### Example — Good vs Bad

**Bad:**
```yaml
description: Helps with documents
```

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

---

## 3. Writing the SKILL.md Body

### Structural Rules

1. **Imperative form.** "Extract the data" not "You should extract the data" or "The data should be extracted."

2. **Explain WHY, not just WHAT.** LLMs have theory of mind. "Format dates as ISO 8601 because downstream APIs reject other formats" beats "ALWAYS use ISO 8601 dates."

3. **Avoid ALL-CAPS enforcement.** If you're writing ALWAYS/NEVER/MUST in caps, reframe as reasoning instead. Heavy-handed constraints get ignored or cause brittle compliance. Exception: genuine safety or data-loss scenarios.

4. **Positive instructions only.** "Respond in JSON" not "Don't respond in plain text." Negatives get ignored or inverted by token prediction.

5. **Include examples.** Show input → output pairs. Models learn patterns from examples faster than from abstract rules.

```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication

**Example 2:**
Input: Fixed crash when uploading empty files
Output: fix(upload): handle empty file edge case
```

6. **Define output format explicitly.** If the skill produces a specific deliverable, template it:

```markdown
## Report structure
Use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

### Content Rules

1. **Don't teach the model what it already knows.** It knows React, Python, SQL. It can see the codebase. Only include domain-specific or proprietary methodology that the model genuinely lacks.

2. **One skill = one workflow.** Don't combine "create presentations" and "analyse spreadsheets" into one skill. Separate concerns = better trigger accuracy.

3. **Bundle repeated work as scripts.** If every invocation requires the same boilerplate (a Python helper, a template generator), write it once, put it in `scripts/`, and reference it from the body. Saves tokens and prevents drift.

4. **Reference heavy resources, don't inline them.** Large schemas, API docs, decision trees → put in `references/` with clear pointers from SKILL.md:

```markdown
## Cloud provider setup
Read the relevant reference file before proceeding:
- AWS: `references/aws.md`
- GCP: `references/gcp.md`
- Azure: `references/azure.md`
```

5. **For large reference files (>300 lines), include a table of contents** so the agent can jump to the relevant section.

---

## 4. The Creation Process

### Do NOT skip the manual walkthrough

Biggest mistake: prompt-engineering a skill into existence from theory. Models map language onto vector space — without grounded examples from YOUR specific workflow, the skill produces confident slop.

**Before codifying any skill:**

1. Identify the manual workflow you want to capture
2. Walk the agent through it step-by-step in live conversation
3. Label outputs correct/incorrect immediately as they appear
4. Complete minimum one fully successful run end-to-end

**Only then** generate the skill file. The agent reviews its own successful context and codifies the exact steps and logic used. This produces grounded skills, not theoretical ones.

### Skillception: Auto-Generation Command

After a successful manual run:

> "Review the previous successful run. Generate a SKILL.md capturing the exact steps, logic, decision points, and output format used."

The generated skill is grounded in proven success. Edit for clarity, but trust the structure.

### Failure = Investment

Every failure improves the skill permanently:

1. Spot the failure point in the output
2. Ask the agent WHY it failed — get the exact error or wrong decision
3. Fix the error in the skill file immediately
4. Re-run to verify the fix

This is a ratchet. Each failure makes the skill permanently better. Angry user moments become moats.

---

## 5. Context Management

### Token Budget Rules

- Context window past 80% = model gets dumb. Hallucinations spike, focus drops
- Static instruction files loaded every turn = token tax. 95% of the time, waste
- Skill descriptions in L1 = ~53 tokens. Full instructions = ~944 tokens. The math is obvious

### Strategic Ordering

Critical information goes at the START and END of context. The middle 40-60% is a reliability trough ("Lost in Middle" effect). Structure skills so the most important instructions appear first and are reinforced at the end.

### What Goes in SKILL.md vs What Doesn't

| Belongs in SKILL.md | Does NOT belong |
|---------------------|-----------------|
| Proprietary methodology | General programming knowledge |
| Domain-specific decision logic | Framework documentation |
| Output format templates | Common API patterns |
| Edge case handling specific to your workflow | Obvious best practices |
| Tool/script references | Model capabilities it already has |

---

## 6. Testing and Iteration

### Test Cases

Write 2-3 realistic test prompts — what a real user would actually type. Not abstract. Include:
- File paths, personal context, casual language
- Edge cases and ambiguous requests
- Mixed lengths and phrasings

**Bad:** `"Format this data"`
**Good:** `"ok so my boss sent me this xlsx (Q4 sales final FINAL v2.xlsx) and she wants profit margin as a percentage. Revenue is column C, costs column D i think"`

### Iteration Loop

1. Run test cases against the skill
2. Evaluate outputs (qualitative review + binary assertions where applicable)
3. Identify failures and gaps
4. Update the skill — generalise from feedback, don't overfit to examples
5. Re-run. Repeat until stable

### Evaluation Principles

- **Binary rubrics** (pass/fail), not Likert scales (1-10). Models drift on scales
- **Position swap** for LLM-as-judge evals: run twice, swap answer order to kill first-choice bias
- **Golden sets from production failures only.** Synthetic happy-path tests don't find real bugs

---

## 7. Anti-Patterns

### Never Do These

| Anti-Pattern | Why It Fails | Fix |
|-------------|-------------|-----|
| Monolithic system prompt | Token tax every turn, intelligence degrades | Progressive disclosure (L1/L2/L3) |
| Teaching model what it knows | Wastes context, can confuse | Only include proprietary/domain knowledge |
| Generic marketplace skills | Can't replicate your nuance, security risk | Build from your own workflows |
| ALWAYS/NEVER/MUST in caps | Brittle compliance, gets ignored | Explain the WHY instead |
| Open-ended agent loops | Budget exhaustion, stuck states | Bounded steps with exit conditions |
| Trusting self-correction | Hallucination loops — can't think out of a mistake you don't know you made | External validator / separate critic |
| Stuffing >20 docs into context | Fragmented recall, reliability trough | Hybrid RAG or progressive loading |
| Identical retry on failure | Same error repeated | Structured retry with error diagnosis |
| Routing on metadata alone | 31-44% accuracy drop | Route on semantic capability match |

---

## 8. Advanced Patterns

### Multi-Domain Skills

When one skill covers multiple variants (cloud providers, frameworks, languages), organise as router + references:

```
cloud-deploy/
├── SKILL.md          # Workflow + selection logic
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

The body contains decision logic for which reference to load. Agent reads only the relevant file.

### Bundled Scripts

For deterministic or repetitive subtasks, write scripts that execute without loading into context:

```
report-generator/
├── SKILL.md
└── scripts/
    ├── build_chart.py
    ├── format_docx.py
    └── validate_schema.py
```

Reference from SKILL.md: "Run `scripts/build_chart.py` with the extracted data." The script executes directly — no token cost.

### Error Recovery in Skills

Build error handling into the skill itself:

```markdown
## Error handling
If the data extraction fails:
1. Log the exact error message
2. Check if the file format matches expectations
3. If format mismatch: attempt conversion, then retry once
4. If still failing: report the specific error to the user with the raw data sample that caused it
Do not retry the same operation identically — diagnose first.
```

### Skill Composition

Skills can reference other skills. Keep dependencies explicit:

```markdown
## Prerequisites
This skill assumes the `pdf-reading` skill has already extracted
the document content. If raw PDF provided, trigger pdf-reading first.
```

---

## 9. Description Optimisation Checklist

Before finalising any skill, verify the description against this checklist:

- [ ] States WHAT the skill does (capability)
- [ ] States WHEN to trigger (contexts, phrases, file types)
- [ ] States WHEN NOT to trigger (negative boundaries)
- [ ] Uses concrete keywords users actually type
- [ ] Under 150 words
- [ ] Pushy enough to overcome undertriggering bias
- [ ] Doesn't overlap ambiguously with other skills
- [ ] Includes casual/informal phrasings, not just formal ones

---

## 10. Skill Quality Rubric

Score any skill against these five criteria:

| Criterion | Pass | Fail |
|-----------|------|------|
| **Triggers correctly** | Fires on relevant prompts, stays silent on irrelevant ones | False positives or misses obvious use cases |
| **Lean context** | L1 under 150 words, L2 under 500 lines, heavy data in L3 | Monolithic, everything in body |
| **Grounded** | Built from successful manual run, includes real examples | Theoretical, no tested workflow |
| **Explains WHY** | Instructions include reasoning the model can generalise from | Rigid rules without rationale |
| **Handles failure** | Explicit error paths, bounded retries, diagnostic output | Silent failures or infinite loops |

---

## Summary: The 10 Commandments of Skill Creation

1. **Progressive disclosure.** L1/L2/L3 tiering. Never dump everything into context.
2. **Description is king.** Pushy, specific, under 150 words. WHAT + WHEN + WHEN NOT.
3. **Manual first.** Walk through the workflow live before codifying anything.
4. **Explain WHY.** Reasoning beats rigid rules. Models generalise from understanding.
5. **Don't teach what's known.** Only proprietary/domain knowledge belongs in skills.
6. **Positive instructions.** Say what TO do. Negatives get inverted.
7. **Include examples.** Input → output pairs. Concrete, not abstract.
8. **Bundle scripts.** Repeated deterministic work = script in `scripts/`, not instructions.
9. **Test with real prompts.** Casual, messy, realistic. Not synthetic happy paths.
10. **Failures are features.** Every error diagnosed and fixed = permanent improvement.
