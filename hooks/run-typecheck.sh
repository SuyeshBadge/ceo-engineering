#!/usr/bin/env bash
# Run typecheck after Edit/Write
# Usage: invoked by Claude Code PostToolUse hook on Edit|Write

set -euo pipefail
INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .args.filePath // ""' 2>/dev/null || echo "")

# Only run on TS/JS files
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) ;;
  *) exit 0 ;;
esac

# Don't recurse on test files (tester handles)
case "$FILE" in
  *.test.*|*.spec.*) exit 0 ;;
esac

# Detect typecheck command
if [[ -f "tsconfig.json" ]]; then
  if command -v tsc >/dev/null 2>&1; then
    tsc --noEmit --pretty false 2>&1 | tail -20 >&2 || true
  elif [[ -f "node_modules/.bin/tsc" ]]; then
    npx tsc --noEmit --pretty false 2>&1 | tail -20 >&2 || true
  fi
elif [[ -f "package.json" ]]; then
  # Try pnpm/npm run typecheck
  if [[ -f "pnpm-lock.yaml" ]] && command -v pnpm >/dev/null 2>&1; then
    pnpm run typecheck 2>&1 | tail -20 >&2 || true
  elif [[ -f "package-lock.json" ]] && command -v npm >/dev/null 2>&1; then
    npm run typecheck 2>&1 | tail -20 >&2 || true
  fi
fi

exit 0
