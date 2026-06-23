---
name: merge-conflict
description: Resolve merge conflicts intelligently. Use when git reports conflicts during merge, rebase, or pull.
allowed-tools: Bash(git:*), Read, Grep, Glob
---

## Status
!`git status`

## Conflicts
!`git diff --name-only --diff-filter=U`

## Branch context
!`git log --oneline -5 main..HEAD 2>/dev/null || git log --oneline -5`
!`git log --oneline -5 HEAD..main 2>/dev/null || echo "no upstream"`

## Instructions

1. Identify the conflict type:
   - **Merge conflict during `git merge`**: two branches changed the same code
   - **Rebase conflict during `git rebase`**: your commits replayed onto new base
   - **Pull conflict**: remote + local diverged
2. For each conflicted file:
   - Read the file in full
   - Identify the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
   - Determine which side(s) to keep:
     - If both sides add different content: combine
     - If both sides modify the same line: understand intent, prefer the more recent or the one matching the test
     - If one side deletes: usually keep unless the deletion breaks tests
3. Spawn `scout` to find related tests + callers before resolving
4. Apply the resolution (Edit the file)
5. Run typecheck + tests for the affected files
6. Mark resolved: `git add <file>`
7. Continue: `git merge --continue` or `git rebase --continue`
8. Report: <list of files resolved, what was kept, what was dropped, test results>
