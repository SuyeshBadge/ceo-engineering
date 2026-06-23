---
name: commit
description: Stage and commit the current changes following Conventional Commits. Use when ready to commit.
disable-model-invocation: true
allowed-tools: Bash(git add:*) Bash(git commit:*) Bash(git status:*) Bash(git diff:*) Bash(git log:*)

## Working tree
!`git status --short`

## Diff stat
!`git diff --stat`

## Recent log (for style)
!`git log --oneline -5`

## Instructions

1. Group changes by concern. One commit per logical change. Don't mix refactors with features.
2. Write a Conventional Commits message: `<type>(<scope>): <subject>`
   - Types: feat, fix, chore, docs, refactor, test, perf, build, ci
3. Subject ≤ 72 chars, imperative mood ("add" not "added"), no trailing period
4. Body: explain *why*, not *what*. Reference issue/PR if applicable
5. Run `git diff --staged` first to verify what will be committed
6. Never use `--no-verify`. Never force-push.

## Output (USER mode — what the CEO sees)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ Committed                                                 │
├─────────────────────────────────────────────────────────────┤
│  hash: a1b2c3d                                              │
│  type:  feat(auth)                                          │
│  files: src/auth/login.ts, src/auth/mfa.ts                  │
│  +47 / -12                                                  │
╰─────────────────────────────────────────────────────────────╯
  → /pr   open a pull request
  → /review  review recent commits
```

## Output (AGENT mode — for subagent context)

```json
{"status":"ok","action":"commit","hash":"a1b2c3d","type":"feat","scope":"auth","subject":"add MFA","files":["src/auth/login.ts","src/auth/mfa.ts"],"additions":47,"deletions":12,"next":["pr","review"]}
```

## Report

After committing, call `report` with:

USER mode (auto-detected from TTY):
```
source ~/.config/opencode/bin/format.sh
report status=ok action=commit hash=a1b2c3d type=feat scope=auth subject="add MFA" files="src/auth/login.ts,src/auth/mfa.ts" cost=0.01 next="/pr,/review"
```

AGENT mode (when output is piped to another agent):
```
report status=ok action=commit hash=a1b2c3d type=feat scope=auth subject="add MFA" files="src/auth/login.ts,src/auth/mfa.ts" cost=0.01
```
