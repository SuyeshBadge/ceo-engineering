#!/usr/bin/env bash
# Block reads of .env files
# Usage: invoked by Claude Code PreToolUse hook on Read|Write|Edit

set -euo pipefail
INPUT=$(cat)

# Extract file path from various payload shapes
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .args.filePath // ""' 2>/dev/null || echo "")

# Allow .env.example, .env.sample, .env.template
case "$FILE" in
  *.env.example|*.env.sample|*.env.template)
    exit 0
    ;;
esac

# Block actual .env files
if [[ "$FILE" =~ \.env($|\.) ]] || [[ "$FILE" =~ /\.env$ ]] || [[ "$FILE" == *.env.local ]] || [[ "$FILE" == *.env.production ]] || [[ "$FILE" == *.env.development ]]; then
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Reading/writing .env files is blocked. Use environment-specific tooling or .env.example as a template."
    }
  }'
  exit 0
fi

exit 0
