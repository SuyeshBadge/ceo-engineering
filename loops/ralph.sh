#!/usr/bin/env bash
# Ralph Wiggum persistent loop
# Usage: ralph.sh [--cost-cap $N] [--time-cap MIN] [PROMPT.md]
# A persistent loop that runs a prompt repeatedly until cost/time cap hit, or file is touched
# Based on https://ghuntley.com/ralph/

set -euo pipefail

COST_CAP=10.00
TIME_CAP=120  # minutes
PROMPT_FILE="PROMPT.md"
STATE_FILE="fix_plan.md"
AGENT_FILE="AGENT.md"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cost-cap) COST_CAP="$2"; shift 2 ;;
    --time-cap) TIME_CAP="$2"; shift 2 ;;
    --prompt)   PROMPT_FILE="$2"; shift 2 ;;
    *)          PROMPT_FILE="$1"; shift ;;
  esac
done

# Defaults
[[ ! -f "$PROMPT_FILE" ]] && { echo "ERROR: $PROMPT_FILE not found"; exit 1; }
[[ ! -f "$STATE_FILE" ]] && cat > "$STATE_FILE" <<EOF
# Fix Plan

Track what needs to be done. The agent updates this each iteration.

## TODO
- [ ] (initial — agent fills in)

## Done
EOF

LOG_DIR="${CEO_LOGS:-$HOME/.config/opencode/logs}"
mkdir -p "$LOG_DIR"
START_TS=$(date +%s)
ITER=0
SPENT=0.0

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Ralph Wiggum Persistent Loop                              ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  Prompt:        $PROMPT_FILE"
echo "║  Plan:          $STATE_FILE"
echo "║  Cost cap:      \$$COST_CAP"
echo "║  Time cap:      $TIME_CAP minutes"
echo "║  Logs:          $LOG_DIR"
echo "╚════════════════════════════════════════════════════════════╝"
echo

# Touch this file to stop the loop gracefully
STOP_FILE=".ralph-stop"
touch "$STOP_FILE"

while true; do
  # Check stop signal
  if [[ ! -f "$STOP_FILE" ]]; then
    echo "$(date -u +%H:%M:%S) 🛑 Stop file removed — exiting"
    break
  fi

  # Check time cap
  NOW=$(date +%s)
  ELAPSED_MIN=$(( (NOW - START_TS) / 60 ))
  if (( ELAPSED_MIN >= TIME_CAP )); then
    echo "$(date -u +%H:%M:%S) ⏰ Time cap hit ($TIME_CAP min) — exiting"
    break
  fi

  # Check cost cap
  if (( $(echo "$SPENT >= $COST_CAP" | bc -l 2>/dev/null || echo 0) )); then
    echo "$(date -u +%H:%M:%S) 💰 Cost cap hit (\$$COST_CAP) — exiting"
    break
  fi

  ITER=$((ITER + 1))
  echo "═══════════════════════════════════════════════════════"
  echo "$(date -u +%H:%M:%S) 🔄 Iteration $ITER  (elapsed: ${ELAPSED_MIN}m, spent: \$$SPENT)"
  echo "═══════════════════════════════════════════════════════"

  # Run the prompt
  set +e
  cat "$PROMPT_FILE" | opencode run --non-interactive 2>&1 | tee -a "$LOG_DIR/ralph-$(date +%Y%m%d).log"
  EXIT=$?
  set -e

  # Estimate cost from log (rough: count tokens in log)
  APPROX_TOKENS=$(wc -w < "$LOG_DIR/ralph-$(date +%Y%m%d).log" 2>/dev/null | tail -1 || echo 0)
  ITER_COST=$(echo "scale=4; $APPROX_TOKENS * 0.000003" | bc -l 2>/dev/null || echo 0.01)
  SPENT=$(echo "scale=4; $SPENT + $ITER_COST" | bc -l)

  echo "$(date -u +%H:%M:%S) ✓ Iteration $ITER done (exit=$EXIT, +\$$ITER_COST, total=\$$SPENT)"

  # If exit 0 AND all done, break
  if [[ $EXIT -eq 0 ]] && grep -q "DONE" "$STATE_FILE" 2>/dev/null; then
    echo "$(date -u +%H:%M:%S) 🎉 DONE marker found in $STATE_FILE — exiting"
    break
  fi

  # Brief pause to avoid hammering
  sleep 2
done

echo
echo "Ralph loop ended after $ITER iterations, \$$SPENT spent, ${ELAPSED_MIN}m elapsed"
echo "To stop manually: rm $STOP_FILE"
