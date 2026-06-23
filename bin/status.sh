#!/usr/bin/env bash
# bin/status.sh — Daily status / metrics dashboard
# Addictive. Run daily. See your progress.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=format.sh
source "$SCRIPT_DIR/format.sh"

PERIOD="${1:-today}"

OC_DIR="$HOME/.config/opencode"
LOG_DIR="$OC_DIR/logs"

# Try to get stats from logs
SESSION_LOG="$LOG_DIR/audit.log"
[[ -f "$LOG_DIR/session-current.log" ]] && SESSION_LOG="$LOG_DIR/session-current.log"

# Compute rough numbers from logs
total_tokens_in=0
total_tokens_out=0
total_cost=0
total_calls=0

if [[ -d "$LOG_DIR" ]]; then
  # Naive parse — adjust based on actual log format
  while IFS= read -r line; do
    if [[ "$line" =~ tokens_in=([0-9]+) ]]; then
      total_tokens_in=$((total_tokens_in + ${BASH_REMATCH[1]}))
    fi
    if [[ "$line" =~ tokens_out=([0-9]+) ]]; then
      total_tokens_out=$((total_tokens_out + ${BASH_REMATCH[1]}))
    fi
    if [[ "$line" =~ cost=([0-9.]+) ]]; then
      total_cost=$(echo "$total_cost + ${BASH_REMATCH[1]}" | bc 2>/dev/null || echo "$total_cost")
    fi
    if [[ "$line" =~ agent=([a-z-]+) ]]; then
      total_calls=$((total_calls + 1))
    fi
  done < <(find "$LOG_DIR" -name "*.log" -mtime -7 2>/dev/null -exec cat {} \; 2>/dev/null) || true
fi

# Header
echo
echo -e "${C_BOLD}${C_CYAN}━━━ CEO Status: $PERIOD ━━━${C_RESET}"
echo

# Hero metric — today's cost
echo -e "  ${C_DIM}Spent${C_RESET}     ${C_BOLD}${C_CYAN}\$${total_cost}${C_RESET}  ${C_DIM}this period${C_RESET}"
echo

# Big numbers
user_header "Numbers"
user_metric "Tokens in"   "$total_tokens_in"  "this week"
user_metric "Tokens out"  "$total_tokens_out" "this week"
user_metric "Calls"       "$total_calls"      "agent invocations"
user_metric "Cost"        "\$${total_cost}"    "this period"
echo

# Goals
user_header "Goals"

# Calculate against $60 monthly cap
MONTHLY_CAP=60
PCT_USED=$(echo "scale=0; $total_cost * 100 / $MONTHLY_CAP" | bc 2>/dev/null || echo 0)
REMAINING=$(echo "scale=2; $MONTHLY_CAP - $total_cost" | bc 2>/dev/null || echo 60)

echo -e "  ${C_DIM}Monthly budget${C_RESET}    \$${MONTHLY_CAP}"
echo -e "  ${C_DIM}Used${C_RESET}             \$${total_cost}  ${C_DIM}(${PCT_USED}%)${C_RESET}"
echo -e "  ${C_DIM}Remaining${C_RESET}        \$${REMAINING}"
echo

# Progress bar
WIDTH=40
FILLED=$(echo "scale=0; $PCT_USED * $WIDTH / 100" | bc 2>/dev/null || echo 0)
EMPTY=$((WIDTH - FILLED))
BAR="${C_GREEN}$(printf '█%.0s' $(seq 1 $FILLED))${C_DIM}$(printf '░%.0s' $(seq 1 $EMPTY))${C_RESET}"
echo -e "  ${BAR}  ${C_DIM}${PCT_USED}%${C_RESET}"
echo

# Streak
if [[ -f "$LOG_DIR/.last-seen" ]]; then
  LAST_SEEN=$(cat "$LOG_DIR/.last-seen")
  TODAY=$(date +%Y-%m-%d)
  if [[ "$LAST_SEEN" == "$TODAY" ]]; then
    echo -e "  ${C_GREEN}${ICON_FIRE} Streak${C_RESET}     ${C_BOLD}active${C_RESET}  ${C_DIM}(today)${C_RESET}"
  fi
fi
date +%Y-%m-%d > "$LOG_DIR/.last-seen" 2>/dev/null || true
echo

# Suggestions based on what they did
user_header "Suggestions"

if (( total_calls == 0 )); then
  user_hint "Try your first command: /commit or /feature 'add X'"
fi

if (( $(echo "$total_cost > 5" | bc 2>/dev/null || echo 0) )); then
  user_hint "Consider running /refactor on a hot module to clean up"
fi

if ! command -v rtk >/dev/null 2>&1; then
  user_hint "Install RTK for 60-90% bash savings: brew install rtk && rtk init -g"
fi

if [[ ! -d "$HOME/.claude/CLAUDE.md" ]] && [[ ! -L "$HOME/.claude/CLAUDE.md" ]]; then
  user_hint "Set up Claude Code too: ln -sf ~/.config/opencode/AGENTS.md ~/.claude/CLAUDE.md"
fi
echo

# Footer
user_divider
user_hint "Read /metrics skill for the in-session version (real-time, per-agent)"
user_hint "Run bin/demo.sh to see the full first-run experience"
echo
