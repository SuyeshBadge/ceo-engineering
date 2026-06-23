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
3. Use `gh pr create` with:
   - **Title**: conventional-commit style, ≤ 72 chars
   - **Body**:
     ```
     ## Summary
     - <2-3 bullets>
     
     ## Test plan
     - [ ] <checkbox>
     
     ## Risks
     - <breaking changes, perf concerns, migration steps>
     ```
   - **Reviewers**: from CODEOWNERS if present
   - **Labels**: infer from commit types (feat → enhancement, fix → bug)
4. Report: PR URL
5. If the user has `/pr-review` set up, mention they can run it after CI passes
