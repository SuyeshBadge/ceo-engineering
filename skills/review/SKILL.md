---
name: review
description: Review uncommitted changes for quality, security, and convention adherence. Use before committing or opening a PR.
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Read, Grep, Glob
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

Output format:
- **Verdict**: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
- **Blockers**: <list, must fix before merge>
- **Majors**: <list, should fix>
- **Minors**: <list, nits>
- **Praise**: <1 thing done well>
