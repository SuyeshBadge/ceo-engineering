---
name: branch
description: Create a new branch with proper naming convention.
disable-model-invocation: true
allowed-tools: Bash(git:*)
---

## Current branch
!`git branch --show-current`

## Default branch
!`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`

## Instructions

1. Detect convention from recent branches:
   !`git branch -a --sort=-committerdate | head -20`
2. If convention unclear, default to: `<type>/<short-desc>` where type is feat, fix, chore, refactor, docs, test
3. Convert `$ARGUMENTS` to a valid branch name (lowercase, hyphens, no spaces)
4. Create and switch: `git checkout -b <name>`
5. Report: branch name + base
