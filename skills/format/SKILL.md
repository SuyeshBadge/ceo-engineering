---
name: format
description: Format code in the working tree. Use after any edit.
disable-model-invocation: true
allowed-tools: Bash, Read
---

## Status
!`git status --short`

## Detected formatters
!`command -v prettier && command -v eslint && command -v black && command -v gofmt || true`

## Instructions

1. Detect the project's formatter from package.json, pyproject.toml, go.mod, etc.
2. Run the appropriate formatter:
   - **JS/TS**: `npx prettier --write .` (or `pnpm format`)
   - **Python**: `black .` and `isort .`
   - **Go**: `gofmt -w .`
   - **Rust**: `cargo fmt`
3. If no formatter detected, skip
4. Report: <number of files formatted>
5. If you have the auto-format hook installed (PostToolUse on Edit|Write), this should run automatically
