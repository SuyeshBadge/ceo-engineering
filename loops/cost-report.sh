#!/usr/bin/env bash
# Cost report for sessions
# Usage: cost-report.sh [day|week|month]

set -euo pipefail

PERIOD="${1:-week}"
LOG_DIR="${CEO_AUDIT_LOG:-$HOME/.config/opencode/logs}"

case "$PERIOD" in
  day)   SINCE="$(date -u -v-1d +%Y-%m-%d 2>/dev/null || date -u -d '1 day ago' +%Y-%m-%d)" ;;
  week)  SINCE="$(date -u -v-7d +%Y-%m-%d 2>/dev/null || date -u -d '7 days ago' +%Y-%m-%d)" ;;
  month) SINCE="$(date -u -v-30d +%Y-%m-%d 2>/dev/null || date -u -d '30 days ago' +%Y-%m-%d)" ;;
  *)     echo "Usage: $0 [day|week|month]"; exit 1 ;;
esac

echo "Cost report — period: $PERIOD (since $SINCE)"
echo "═══════════════════════════════════════════════════════"
echo

if [[ ! -d "$LOG_DIR" ]] || [[ -z "$(ls -A "$LOG_DIR" 2>/dev/null)" ]]; then
  echo "No log files yet."
  echo "Set CEO_AUDIT_LOG to a custom log dir, or wait for hooks to populate $LOG_DIR"
  exit 0
fi

# Aggregate from log files newer than $SINCE
echo "Sessions:"
find "$LOG_DIR" -name "*.log" -newer "$LOG_DIR/.touch" 2>/dev/null | while read -r f; do
  echo "  $(basename "$f")"
done

echo
echo "Note: detailed cost tracking requires session-level data not yet captured."
echo "Use /metrics skill in opencode for live session metrics."
