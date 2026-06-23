---
name: lint
description: Run the project's linter and report issues. Use before committing.
allowed-tools: Bash, Read
---

## Status
!`git status --short`

## Detected linters
!`command -v eslint && command -v ruff && command -v golangci-lint && command -v clippy-driver || true`

## Instructions

1. Detect the project's linter
2. Run it on the changed files (faster than full project):
   - **JS/TS**: `npx eslint $(git diff --name-only --diff-filter=ACMR | grep -E '\.(ts|tsx|js|jsx)$')` or `pnpm lint`
   - **Python**: `ruff check .` or `flake8`
   - **Go**: `golangci-lint run ./...`
   - **Rust**: `cargo clippy`
3. If issues found:
   - Auto-fix what can be fixed: `--fix` flag
   - Report the rest with file:line
4. Report: <errors / warnings / clean>
