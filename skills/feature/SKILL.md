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

## Output (USER mode)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Feature complete: Add MFA to login                       │
├─────────────────────────────────────────────────────────────┤
│  src/auth/login.ts:42-89    added MFA flow                 │
│  src/auth/mfa.ts:1-156      new MFA module                  │
│  tests/auth/mfa.test.ts     8 new tests                     │
│                                                             │
│  ────────────────────────────────────────────────────────   │
│  Tests       12/12 ✓      Typecheck     clean ✓            │
│  Lint        clean ✓      Cost          $0.42               │
│  Time        4.2s         Cache         78% hit             │
│  Model       minimax-m3   Agents        8 calls            │
│                                                             │
│  Subagents: scout, builder, reviewer, tester, doc-writer    │
╰─────────────────────────────────────────────────────────────╯
  → /commit      stage and commit
  → /pr          open a pull request
  → /review      review the changes
  → /refactor    if you want changes
  → /security    if auth/payments/PII touched
```

## Output (AGENT mode — what other agents read)

```json
{"status":"ok","action":"feature_complete","target":"add_mfa","files":[{"path":"src/auth/login.ts","lines":"42-89","action":"added_mfa_flow"},{"path":"src/auth/mfa.ts","lines":"1-156","action":"new_module"}],"tests":"12/12","typecheck":"clean","lint":"clean","cost_usd":0.42,"time_sec":4.2,"cache_hit_rate":0.78,"model":"minimax-m3","agent_calls":8,"subagents":["scout","builder","reviewer","tester","doc-writer"],"next":["commit","pr"]}
```

## Report (CEO uses both modes automatically)

The CEO's last action in the pipeline is to call `report` with all the data:

```bash
source ~/.config/opencode/bin/format.sh
report \
  status=ok \
  action=feature_complete \
  target="add_mfa_to_login" \
  files="src/auth/login.ts:42-89,src/auth/mfa.ts:1-156,tests/auth/mfa.test.ts" \
  tests=12/12 \
  typecheck=clean \
  lint=clean \
  cost=0.42 \
  time=4.2 \
  cache_hit="78%" \
  model=minimax-m3 \
  detail="8 new tests" \
  next="/commit,/pr,/review"
```

When piped to another agent, this becomes compact JSON. When printed to the user's TUI, this becomes a beautiful box.
