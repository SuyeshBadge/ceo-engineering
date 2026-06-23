---
name: feature
description: Full feature implementation pipeline. Use for new features spanning multiple files.
---

## Feature request
$ARGUMENTS

## Pipeline

1. **PARSE** — understand intent, flag ambiguity to user
2. **SCOUT** — spawn `scout` (background) to map relevant code
3. **PLAN** — if non-trivial (3+ files), spawn `architect` for design
4. **DELEGATE** — spawn `builder` with task + scout's summary + plan
5. **REVIEW** — spawn `reviewer` (parallel with tester)
6. **TEST** — spawn `tester` (foreground, blocks)
7. **LOOP** — if issues, return to step 4 (cap 4 iterations)
8. **SHIP** — spawn `doc-writer` (background) + run `/commit`
9. **REPORT** — CEO reports in CEO language

## Output (CEO language)
- **Status**: Done / In progress / Blocked / Failed
- **What changed**: file:line
- **Verification**: tests/typecheck/lint results
- **Cost**: $X.XX
- **Risk flags**: ⚠️
- **Next step**: commit? ship? investigate?
