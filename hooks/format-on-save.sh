#!/usr/bin/env bash
# Auto-format on save
# Usage: invoked by Claude Code PostToolUse hook on Edit|Write

set -euo pipefail
INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .args.filePath // ""' 2>/dev/null || echo "")

# Skip if no file
[[ -z "$FILE" || ! -f "$FILE" ]] && exit 0

# Skip non-source files
case "$FILE" in
  *.md|*.txt|*.json|*.lock|*.yaml|*.yml|*.toml) exit 0 ;;
esac

# Detect formatter by extension
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.vue|*.svelte)
    if command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE" --log-level silent 2>/dev/null || true
    elif [[ -f "node_modules/.bin/prettier" ]]; then
      npx prettier --write "$FILE" --log-level silent 2>/dev/null || true
    fi
    ;;
  *.py)
    if command -v black >/dev/null 2>&1; then
      black "$FILE" --quiet 2>/dev/null || true
    fi
    if command -v isort >/dev/null 2>&1; then
      isort "$FILE" --quiet 2>/dev/null || true
    fi
    ;;
  *.go)
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w "$FILE" 2>/dev/null || true
    fi
    ;;
  *.rs)
    if command -v rustfmt >/dev/null 2>&1; then
      rustfmt "$FILE" 2>/dev/null || true
    fi
    ;;
  *.sh|*.bash)
    if command -v shfmt >/dev/null 2>&1; then
      shfmt -w "$FILE" 2>/dev/null || true
    fi
    ;;
esac

exit 0
