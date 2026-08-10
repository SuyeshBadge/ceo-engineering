#!/usr/bin/env bash
# Block delegations to builder/builder-quick whose own prompt admits the
# task is read-only (no edit, no mutation) — that work is cheaper and
# correctly scoped on scout/research/architect. builder runs a stronger
# model at higher reasoning effort; routing a no-mutation task to it is
# pure cost waste on top of a role-separation violation.
# Usage: invoked by opencode safety-hooks plugin on the task tool.
# Exit 0 + JSON permissionDecision: "deny" = block

set -euo pipefail
INPUT=$(cat)

emit_deny() {
  local reason="$1"
  /usr/bin/python3 - "$reason" <<'PY'
import json
import sys

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": sys.argv[1],
    }
}, separators=(",", ":")))
PY
  exit 0
}

trap 'status=$?; emit_deny "guard-readonly-builder hook failed closed at line ${LINENO} (status ${status})"' ERR

set +e
if REASON=$(PAYLOAD="$INPUT" /usr/bin/python3 - 2>&1 <<'PY'
import json
import os
import re


def fail(reason: str) -> None:
    print(reason)
    raise SystemExit(2)


READONLY_PATTERNS = (
    r"\bread[- ]only\b",
    r"\bdo not edit (?:any )?files\b",
    r"\bdon'?t edit (?:any )?files\b",
    r"\bnever edit files\b",
    r"\bdo not modify (?:any )?files\b",
    r"\bdo not change (?:any )?files\b",
    r"\bno (?:file|code) (?:edits|changes|modifications)\b",
    r"\bwithout (?:editing|modifying|writing to|changing)\b",
)

payload_text = os.environ.get("PAYLOAD", "")
try:
    payload = json.loads(payload_text)
except Exception:
    fail("malformed task hook payload")
if not isinstance(payload, dict):
    fail("malformed task hook payload")

tool_input = payload.get("tool_input", payload) if isinstance(payload.get("tool_input", payload), dict) else {}
subagent = str(tool_input.get("subagent_type") or tool_input.get("subagentType") or "").strip().lower()

if subagent not in ("builder", "builder-quick"):
    raise SystemExit(0)

prompt = str(tool_input.get("prompt") or "")
description = str(tool_input.get("description") or "")
haystack = f"{description}\n{prompt}"

for pattern in READONLY_PATTERNS:
    match = re.search(pattern, haystack, flags=re.I)
    if match:
        fail(
            f"this '{subagent}' delegation reads as read-only work (prompt matched "
            f"'{match.group(0)}') — read-only/no-mutation tasks must route to "
            f"scout/research/architect, never builder (see AGENTS.md § MCP capability "
            f"map / § Scope discipline; scout now also holds a narrow ClickUp read grant "
            f"for the current branch's own ticket). If scout/research genuinely lack a tool "
            f"this needs, say so and grant it there rather than routing through builder."
        )

raise SystemExit(0)
PY
); then
  STATUS=0
else
  STATUS=$?
fi
set -e

if [[ $STATUS -eq 2 ]]; then
  emit_deny "$REASON"
elif [[ $STATUS -ne 0 ]]; then
  emit_deny "unable to inspect task delegation safely: ${REASON:-unknown parser failure}"
fi

# Nothing blocked — exit 0 silently
exit 0
