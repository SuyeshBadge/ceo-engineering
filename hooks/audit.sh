#!/usr/bin/env bash
# Audit log of session/tool activity
# Usage: invoked by SessionStart / SessionEnd hooks

set -euo pipefail
ACTION="${1:-event}"

LOG_DIR="${CEO_AUDIT_LOG:-$HOME/.config/opencode/logs}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/audit.log"

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[$TS] [$ACTION] $*" >> "$LOG_FILE"

# On session end, summarize
if [[ "$ACTION" == "session-end" ]]; then
  INPUT=$(cat 2>/dev/null || echo "{}")
  echo "[$TS] [summary] $INPUT" >> "$LOG_FILE"
fi

exit 0
