---
name: sync
description: Sync the current branch with the default branch (rebase preferred).
disable-model-invocation: true
allowed-tools: Bash(git:*)
---

## Current branch
!`git branch --show-current`

## Default branch
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`

## Status
!`git status --short`

## Instructions

1. Fetch the latest: `git fetch origin`
2. Check for uncommitted changes — if any, warn and ask before proceeding
3. Rebase onto default: `git rebase origin/<default>` (preferred over merge for clean history)
4. If conflicts: delegate to `/merge-conflict` skill
5. After successful rebase: `git push --force-with-lease` (NEVER `--force` to main/master)
6. Report: <N commits rebased, any conflicts resolved>
