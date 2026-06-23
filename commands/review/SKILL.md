---
description: Review uncommitted changes for quality, security, and convention adherence. Use before committing or opening a PR.
agent: reviewer
---

## Staged changes
!`git diff --cached`

## Unstaged changes
!`git diff`

## Recent commits
!`git log --oneline -10`

## Instructions

Delegate to the **reviewer** subagent with the diff above. Group findings by severity (Blocker / Major / Minor / Nit). Cite `file:line` for every finding.

If the diff is empty, say so and exit.

## Output (USER mode)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Review complete: APPROVE                                 │
├─────────────────────────────────────────────────────────────┤
│  3 files, 47 lines                                          │
│                                                             │
│  Blocker  (must fix before merge)                           │
│    (none)                                                   │
│                                                             │
│  Major    (should fix)                                      │
│    src/auth/login.ts:42   verifyToken missing null check   │
│                                                             │
│  Minor    (nit)                                             │
│    src/auth/mfa.ts:23     prefer `const` over `let`         │
│                                                             │
│  Praise                                                     │
│    tests/auth/mfa.test.ts comprehensive edge case coverage  │
╰─────────────────────────────────────────────────────────────╯
  → /commit     if you're happy
  → /bug "X"   if a finding is worth fixing now
```

## Output (AGENT mode)

```json
{"status":"ok","action":"review","verdict":"APPROVE","files":3,"lines":47,"blockers":[],"majors":[{"file":"src/auth/login.ts","line":42,"msg":"verifyToken missing null check"}],"minors":[{"file":"src/auth/mfa.ts","line":23,"msg":"prefer const over let"}],"praise":[{"file":"tests/auth/mfa.test.ts","msg":"comprehensive edge case coverage"}]}
```

## Report

```
report status=ok action=review verdict=APPROVE files=3 lines=47 detail="1 major, 1 minor" next="/commit"
```
