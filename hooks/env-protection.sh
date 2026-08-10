#!/usr/bin/env bash
# Block file-tool access to real .env files.
# Usage: invoked by opencode safety-hooks plugin on Read|Write|Edit.
# Bash .env writes/redirections are handled by block-destructive.sh.

set -euo pipefail
INPUT=$(cat)

emit_deny() {
  local reason="$1"
  jq -nc --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Reject empty stdin or invalid JSON up front. jq exits 0 with no output on
# empty input, so it will not surface as a command failure below — check
# explicitly to avoid a fail-open gap.
if [[ -z "$INPUT" ]] || ! printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1; then
  emit_deny "malformed hook payload: input is empty or not valid JSON"
fi

# Extract file path from various payload shapes. If jq itself fails here
# (e.g. unexpected structure), fail closed (deny) rather than silently
# allowing the tool call through.
if ! FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .args.filePath // ""' 2>/dev/null); then
  emit_deny "malformed hook payload: unable to parse tool input safely"
fi

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
