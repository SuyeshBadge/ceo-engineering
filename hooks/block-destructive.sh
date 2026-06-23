#!/usr/bin/env bash
# Block destructive commands
# Usage: invoked by Claude Code PreToolUse hook on Bash tool
# Exit 0 + JSON permissionDecision: "deny" = block

set -euo pipefail
INPUT=$(cat)

# Extract command from Claude Code hook payload
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Also handle opencode plugin payload shape
if [[ -z "$CMD" ]]; then
  CMD=$(echo "$INPUT" | jq -r '.args.command // ""' 2>/dev/null || echo "")
fi

# Destructive patterns
if echo "$CMD" | grep -qE 'rm\s+-rf\s+/'; then
  emit_deny "rm -rf / is never allowed"
fi

if echo "$CMD" | grep -qE 'rm\s+-rf\s+\*'; then
  emit_deny "rm -rf with wildcard requires explicit approval"
fi

if echo "$CMD" | grep -qE 'git\s+push\s+.*--force.*\s+(main|master)'; then
  emit_deny "Force-push to main/master is never allowed"
fi

if echo "$CMD" | grep -qE ':\(\)\s*\{.*:\|:.*&.*\}\s*;:\s*'; then
  emit_deny "Fork bomb blocked"
fi

if echo "$CMD" | grep -qE 'curl\s+.*\|\s*(ba)?sh'; then
  emit_deny "Pipe-to-shell blocked — download scripts to a file first and review"
fi

if echo "$CMD" | grep -qE 'dd\s+.*of=/dev/(sd|nvme|hd)'; then
  emit_deny "Writing to raw block devices is not allowed"
fi

if echo "$CMD" | grep -qE 'mkfs\.'; then
  emit_deny "Filesystem creation not allowed"
fi

# Nothing blocked — exit 0 silently
exit 0

emit_deny() {
  local reason="$1"
  jq -nc --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}
