#!/usr/bin/env bash
# Bounded structured audit log of session/tool activity.
# Usage: JSON payload on stdin from the OpenCode safety-hooks plugin.

set -euo pipefail
umask 077

MAX_INPUT=16384
INPUT=$(cat)
if (( ${#INPUT} > MAX_INPUT )); then
  printf 'audit payload exceeds %s bytes\n' "$MAX_INPUT" >&2
  exit 2
fi

DEFAULT_ROOT="${HOME:-/tmp}"
LOG_DIR="${CEO_AUDIT_LOG:-$DEFAULT_ROOT/.config/opencode-audit}"

PAYLOAD="$INPUT" /usr/bin/python3 - "$LOG_DIR" <<'PY'
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import sys


def object_or_empty(value):
    return value if isinstance(value, dict) else {}


def sanitized(value, limit):
    if not isinstance(value, str):
        return ""
    printable = "".join(character if character >= " " and character != "\x7f" else " " for character in value)
    return " ".join(printable.split())[:limit]


try:
    payload = json.loads(os.environ.get("PAYLOAD", ""))
except json.JSONDecodeError as error:
    raise SystemExit(f"invalid audit payload: {error}") from error
if not isinstance(payload, dict):
    raise SystemExit("invalid audit payload: expected an object")

args = object_or_empty(payload.get("args"))
tool_input = object_or_empty(payload.get("tool_input"))
properties = object_or_empty(payload.get("properties"))
record = {
    "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
    "event": sanitized(payload.get("event"), 64),
    "tool": sanitized(payload.get("tool_name"), 64),
    "file_path": sanitized(
        args.get("filePath") or args.get("path") or tool_input.get("file_path") or tool_input.get("path"),
        512,
    ),
    "command": sanitized(args.get("command") or tool_input.get("command"), 512),
    "reason": sanitized(payload.get("reason"), 256),
    "session_id": sanitized(
        payload.get("session_id")
        or payload.get("sessionID")
        or properties.get("sessionID")
        or properties.get("id"),
        128,
    ),
}

log_dir = Path(sys.argv[1])
log_dir.mkdir(parents=True, exist_ok=True)
with (log_dir / "audit.log").open("a", encoding="utf-8") as log:
    log.write(json.dumps(record, sort_keys=True, separators=(",", ":"), ensure_ascii=True))
    log.write("\n")
PY

exit 0
