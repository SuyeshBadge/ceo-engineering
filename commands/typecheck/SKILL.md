---
description: Run the TypeScript / type checker and report errors. Use after any type-related change.
agent: builder
---

## Status
!`git status --short`

## Detected checkers
!`command -v tsc && command -v mypy && command -v pyright || true`

## Instructions

1. Detect the project's type checker:
   - **TypeScript**: `npx tsc --noEmit` (or `pnpm typecheck`)
   - **Python**: `mypy .` or `pyright`
2. Run it. If no checker detected, skip.
3. If errors:
   - List with file:line + 1-line description
   - Suggest fix for each
4. Report: <clean / N errors / N warnings>
