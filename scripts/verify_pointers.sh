#!/usr/bin/env bash
# Verify that the section pointers in SKILL.md still resolve to real headings
# in upstream skill-creator/SKILL.md. Run this after any skill-creator update.
#
# Exit 0 = all pointers resolve. Exit 1 = at least one missing.

set -euo pipefail

SKILL_CREATOR="${SKILL_CREATOR_PATH:-$HOME/.claude/skills/skill-creator/SKILL.md}"

if [[ ! -f "$SKILL_CREATOR" ]]; then
  echo "FAIL: skill-creator not found at $SKILL_CREATOR"
  echo "Set SKILL_CREATOR_PATH or install skill-creator first."
  exit 1
fi

# Pointers we rely on. Format: "label|exact heading regex"
POINTERS=(
  "Running and evaluating test cases (H2)|^## Running and evaluating test cases$"
  "Step 1: Spawn all runs|^### Step 1: Spawn all runs"
  "Step 2: While runs are in progress|^### Step 2: While runs are in progress"
  "Step 3: As runs complete|^### Step 3: As runs complete"
  "Step 4: Grade, aggregate, and launch the viewer|^### Step 4: Grade, aggregate, and launch the viewer"
  "Step 5: Read the feedback|^### Step 5: Read the feedback"
  "Improving the skill (H2)|^## Improving the skill$"
  "Description Optimization (H2)|^## Description Optimization$"
  "Step 3: Run the optimization loop|^### Step 3: Run the optimization loop"
  "Package and Present|^### Package and Present"
  "Communicating with the user (H2)|^## Communicating with the user$"
)

missing=0
for p in "${POINTERS[@]}"; do
  label="${p%%|*}"
  pattern="${p##*|}"
  if grep -qE "$pattern" "$SKILL_CREATOR"; then
    printf "  ok   %s\n" "$label"
  else
    printf "  MISS %s  (regex: %s)\n" "$label" "$pattern"
    missing=$((missing + 1))
  fi
done

echo
if [[ $missing -eq 0 ]]; then
  echo "PASS: all $((${#POINTERS[@]})) pointers resolve."
  exit 0
else
  echo "FAIL: $missing pointer(s) missing in $SKILL_CREATOR"
  echo "Update SKILL.md 'Delegated mechanics' table to match current upstream headings."
  exit 1
fi
