---
name: test
description: Run targeted tests based on the recent diff. Use to verify changes don't break anything.
allowed-tools: Bash(npm test:*), Bash(pnpm test:*), Bash(yarn test:*), Bash(pytest:*), Bash(go test:*), Bash(cargo test:*), Bash(git:*), Read, Grep
---

## Recent diff
!`git diff --name-only HEAD~1 HEAD 2>/dev/null || git diff --name-only`

## Instructions

1. Identify the changed files
2. Map them to test files (e.g. `src/foo.ts` → `src/foo.test.ts` or `tests/foo.test.ts`)
3. Run only the relevant tests:
   - `pnpm test --run <pattern>` (or project's test command)
   - For Python: `pytest <test_file>::<test_name>`
   - For Go: `go test ./path/...`
4. If tests fail, show the failure output
5. Run typecheck if project has it: `pnpm typecheck` or `tsc --noEmit`
6. Run linter: `pnpm lint` or project's equivalent
7. Report: pass/fail count, time, flaky tests, recommendations
