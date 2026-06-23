---
name: clean
description: Clean up local merged branches. Use periodically to keep the working tree tidy.
disable-model-invocation: true
allowed-tools: Bash(git:*)
---

## Default branch
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`

## Merged local branches
!`git branch --merged origin/main | grep -v '^\*\|main\|master'`

## Stale branches (no commits in 90 days)
!`git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(committerdate:iso8601)' | awk '$2 < (strftime("%Y-%m-%d", systime()-90*24*3600))'`

## Instructions

1. Show the user the list of merged branches that would be deleted
2. Ask for confirmation (default: dry-run, list only)
3. After confirmation: `git branch -d <name>` (lowercase `-d` — refuses if not merged)
4. For stale branches: ask before `-D` (force delete)
5. Prune remote tracking: `git remote prune origin`
6. Report: <N branches deleted, N pruned>
