---
name: pr
description: Open a pull request for the current branch. Use when ready to merge.
disable-model-invocation: true
allowed-tools: Bash(gh:*), Bash(git:*), Read, Grep, Glob
---

## Branch
!`git branch --show-current`

## Commits since main
!`git log main..HEAD --oneline 2>/dev/null || git log --oneline -10`

## Diff stat
!`git diff main...HEAD --stat 2>/dev/null || git diff --stat`

## Instructions

1. Confirm branch follows naming convention (e.g. `feat/`, `fix/`, `chore/`). Warn if not.
2. Push the branch: `git push -u origin HEAD`
3. Use `gh pr create` with conventional-commit style
4. Report in the format below

## Output (USER mode)

```
╭─────────────────────────────────────────────────────────────╮
│ ✓ PR opened                                                 │
├─────────────────────────────────────────────────────────────┤
│  https://github.com/org/repo/pull/123                       │
│                                                             │
│  Title:  feat(auth): add MFA to login                       │
│  Files:  3 changed (+47 / -12)                              │
│  Labels: enhancement                                        │
╰─────────────────────────────────────────────────────────────╯
  → /pr-review <url>  (after CI passes)
  → /merge-conflict   (if conflicts arise)
```

## Output (AGENT mode)

```json
{"status":"ok","action":"pr_opened","url":"https://github.com/org/repo/pull/123","title":"feat(auth): add MFA","files_changed":3,"additions":47,"deletions":12,"labels":["enhancement"]}
```

## Report

```
report status=ok action=pr_opened url="https://github.com/org/repo/pull/123" files=3 detail="feat(auth): add MFA" next="/pr-review,/merge-conflict"
```
