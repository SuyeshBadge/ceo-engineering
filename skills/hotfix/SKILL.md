---
name: hotfix
description: Emergency fix branch from main. Use for production incidents.
disable-model-invocation: true
allowed-tools: Bash(git:*), Read, Grep
---

## Current branch
!`git branch --show-current`

## Status
!`git status --short`

## Instructions

1. Confirm: a hotfix is for an active production issue. If unclear, ask.
2. Fetch latest: `git fetch origin`
3. Create branch from main: `git checkout -b hotfix/<short-desc> origin/main`
4. Push immediately: `git push -u origin hotfix/<short-desc>`
5. Delegate to `/bug` skill with the user's description
6. After the fix lands and merges, tag the release (delegate to `/release`)
7. Report: branch name, PR link when opened
