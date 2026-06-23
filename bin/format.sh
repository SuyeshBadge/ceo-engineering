#!/usr/bin/env bash
# bin/format.sh — The output language
# Two modes: USER (pretty) and AGENT (token-efficient)
# Source this from skills, hooks, and agents.
#
# Usage:
#   source bin/format.sh
#   user_box "Feature complete" "Add MFA"  # pretty box
#   agent_json status=ok action=done       # compact JSON
#   report "Feature complete" "Add MFA" --mode=user  # auto-format
#
# All functions auto-detect mode from $CEO_MODE env var if not specified.

set -euo pipefail

# ============ COLORS (USER mode) ============
if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[0;31m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[1;33m'
  C_BLUE=$'\033[0;34m'
  C_MAGENTA=$'\033[0;35m'
  C_CYAN=$'\033[0;36m'
  C_GRAY=$'\033[0;90m'
else
  C_RESET="" C_BOLD="" C_DIM="" C_RED="" C_GREEN="" C_YELLOW=""
  C_BLUE="" C_MAGENTA="" C_CYAN="" C_GRAY=""
fi

# ============ ICONS ============
ICON_OK="✓"
ICON_WARN="⚠"
ICON_FAIL="✗"
ICON_INFO="ℹ"
ICON_ARROW="→"
ICON_DOT="•"
ICON_FIRE="🔥"
ICON_DART="🎯"
ICON_HOOK="⚡"

# ============ MODE DETECTION ============
# CEO_MODE = "user" | "agent" | auto-detect
get_mode() {
  if [[ -n "${CEO_MODE:-}" ]]; then
    echo "$CEO_MODE"
    return
  fi
  # Auto-detect: if stdout is a TTY, user mode; otherwise agent
  if [[ -t 1 ]]; then
    echo "user"
  else
    echo "agent"
  fi
}

# ============ STATUS ============
# user: "✓ Done"  agent: "status=ok"
status_icon() {
  case "$1" in
    ok|done|success|pass) echo "$ICON_OK" ;;
    warn|warning) echo "$ICON_WARN" ;;
    fail|error|blocked) echo "$ICON_FAIL" ;;
    info|running) echo "$ICON_INFO" ;;
    *) echo "$ICON_DOT" ;;
  esac
}

status_code() {
  case "$1" in
    ok|done|success|pass) echo "ok" ;;
    warn|warning) echo "warn" ;;
    fail|error|blocked) echo "fail" ;;
    info|running) echo "info" ;;
    *) echo "$1" ;;
  esac
}

# ============ BOX (USER mode) ============
# Pretty box around content
# user_box "title" "subtitle" "body..."
user_box() {
  [[ "$(get_mode)" != "user" ]] && { agent_box "$@"; return; }
  local title="$1"
  local subtitle="${2:-}"
  shift 2 || shift 1
  local body="$*"

  local width=65
  echo -e "${C_BOLD}${C_CYAN}╭$(printf '─%.0s' $(seq 1 $width))╮${C_RESET}"
  echo -e "${C_BOLD}${C_CYAN}│${C_RESET} ${C_BOLD}${title}${C_RESET}${C_DIM}${subtitle:+ — $subtitle}${C_RESET}"
  if [[ -n "$body" ]]; then
    echo -e "${C_BOLD}${C_CYAN}├$(printf '─%.0s' $(seq 1 $width))┤${C_RESET}"
    echo -e "$body" | while IFS= read -r line; do
      printf "${C_BOLD}${C_CYAN}│${C_RESET} %-${width}s${C_BOLD}${C_CYAN}│${C_RESET}\n" "$line"
    done
  fi
  echo -e "${C_BOLD}${C_CYAN}╰$(printf '─%.0s' $(seq 1 $width))╯${C_RESET}"
}

# ============ BOX (AGENT mode) ============
# Compact JSON box
agent_box() {
  local title="$1"
  local subtitle="${2:-}"
  local body="$3"
  jq -nc \
    --arg t "$title" \
    --arg s "$subtitle" \
    --arg b "$body" \
    '{title: $t, subtitle: $s, body: $b}'
}

# ============ REPORT (the main function) ============
# The most common output. Both modes.
# Usage:
#   report status=ok action=feature_complete target="Add MFA" files="a.ts,b.ts" cost=0.42
# Or with named args:
#   report --status ok --action feature_complete --target "Add MFA" --cost 0.42
report() {
  local mode="${CEO_MODE_OVERRIDE:-$(get_mode)}"

  if [[ "$mode" == "user" ]]; then
    _report_user "$@"
  else
    _report_agent "$@"
  fi
}

# Parse key=value or --key value
_parse_kv() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --*) local key="${1#--}"; local val="$2"; shift 2; echo "$key=$val" ;;
      *) echo "$1"; shift ;;
    esac
  done
}

_report_user() {
  local _status="" _action="" _target="" _body="" _cost="" _time="" _files="" _next="" _risk="" _verdict="" _detail="" _tests="" _typecheck="" _lint="" _model="" _cache_hit=""

  for arg in "$@"; do
    case "$arg" in
      status=*) _status="${arg#status=}" ;;
      action=*) _action="${arg#action=}" ;;
      target=*) _target="${arg#target=}" ;;
      body=*) _body="${arg#body=}" ;;
      cost=*) _cost="${arg#cost=}" ;;
      time=*) _time="${arg#time=}" ;;
      files=*) _files="${arg#files=}" ;;
      next=*) _next="${arg#next=}" ;;
      risk=*) _risk="${arg#risk=}" ;;
      verdict=*) _verdict="${arg#verdict=}" ;;
      detail=*) _detail="${arg#detail=}" ;;
      tests=*) _tests="${arg#tests=}" ;;
      typecheck=*) _typecheck="${arg#typecheck=}" ;;
      lint=*) _lint="${arg#lint=}" ;;
      model=*) _model="${arg#model=}" ;;
      cache_hit=*) _cache_hit="${arg#cache_hit=}" ;;
    esac
  done

  local title
  if [[ -n "$_action" ]]; then
    title="$(status_icon "$_status") ${_action//_/ }"
  else
    title="$(status_icon "$_status") ${_target:-(no action)}"
  fi
  [[ -n "$_target" ]] && title="$title: $_target"

  local icon status_color
  icon=$(status_icon "$_status")
  case "$_status" in
    ok|done|success|pass) status_color="$C_GREEN" ;;
    warn|warning) status_color="$C_YELLOW" ;;
    fail|error|blocked) status_color="$C_RED" ;;
    *) status_color="$C_CYAN" ;;
  esac

  # Build the body
  local out=""
  out+="${status_color}${icon}${C_RESET} ${C_BOLD}${title}${C_RESET}\n"
  [[ -n "$_detail" ]] && out+="${C_DIM}${_detail}${C_RESET}\n"
  if [[ -n "$_files" ]]; then
    out+="\n${C_DIM}Files:${C_RESET}\n"
    echo "$_files" | tr ',' '\n' | while IFS= read -r f; do
      out+="  ${C_CYAN}${ICON_DOT}${C_RESET} $f\n"
    done
  fi
  if [[ -n "$_tests" ]] || [[ -n "$_typecheck" ]] || [[ -n "$_lint" ]] || [[ -n "$_cost" ]]; then
    out+="\n${C_DIM}─────────────────────────${C_RESET}\n"
    [[ -n "$_tests" ]] && out+="  ${C_DIM}Tests${C_RESET}     ${_tests}\n"
    [[ -n "$_typecheck" ]] && out+="  ${C_DIM}Typecheck${C_RESET} ${_typecheck}\n"
    [[ -n "$_lint" ]] && out+="  ${C_DIM}Lint${C_RESET}      ${_lint}\n"
    [[ -n "$_cost" ]] && out+="  ${C_DIM}Cost${C_RESET}      \$${_cost}\n"
    [[ -n "$_time" ]] && out+="  ${C_DIM}Time${C_RESET}      ${_time}s\n"
    [[ -n "$_model" ]] && out+="  ${C_DIM}Model${C_RESET}     ${_model}\n"
    [[ -n "$_cache_hit" ]] && out+="  ${C_DIM}Cache${C_RESET}     ${_cache_hit} hit\n"
  fi
  [[ -n "$_risk" ]] && out+="\n${C_YELLOW}${ICON_WARN} ${_risk}${C_RESET}\n"
  [[ -n "$_next" ]] && out+="\n${C_DIM}${ICON_ARROW} ${_next}${C_RESET}\n"

  echo -e "$out"
}

_report_agent() {
  local json="{"
  local first=true
  for arg in "$@"; do
    local key="${arg%%=*}"
    local val="${arg#*=}"
    if [[ "$first" == true ]]; then
      first=false
    else
      json+=","
    fi
    # Auto-quote values unless they look numeric
    if [[ "$val" =~ ^[0-9.]+$ ]]; then
      json+="\"$key\":$val"
    else
      json+="\"$key\":\"$val\""
    fi
  done
  json+="}"
  echo "$json"
}

# ============ LIST (USER mode) ============
# Pretty list
# user_list "Title" "item1" "item2" ...
user_list() {
  [[ "$(get_mode)" != "user" ]] && { agent_list "$@"; return; }
  local title="$1"; shift
  echo -e "${C_BOLD}${title}${C_RESET}"
  for item in "$@"; do
    echo -e "  ${C_CYAN}${ICON_DOT}${C_RESET} $item"
  done
}

agent_list() {
  local title="$1"; shift
  local items=$(printf '"%s",' "$@" | sed 's/,$//')
  jq -nc --arg t "$title" "{title:\$t, items:[$items]}"
}

# ============ TABLE (USER mode) ============
# Aligned table
# user_table "Header" "col1 col2 col3" "val1 val2 val3" ...
user_table() {
  [[ "$(get_mode)" != "user" ]] && { agent_table "$@"; return; }
  local title="$1"; shift
  echo -e "${C_BOLD}${title}${C_RESET}"
  local IFS=$'\n'
  printf "  %s\n" "$*"
}

agent_table() {
  local title="$1"; shift
  jq -nc --arg t "$title" --arg rows "$*" '{title: $t, rows: $rows}'
}

# ============ METRIC (USER mode) ============
# Big number with label
# user_metric "Cost" "$0.42" "this session"
user_metric() {
  [[ "$(get_mode)" != "user" ]] && { agent_metric "$@"; return; }
  local label="$1" value="$2" sub="${3:-}"
  echo -e "  ${C_DIM}${label}${C_RESET}  ${C_BOLD}${C_CYAN}${value}${C_RESET}  ${C_DIM}${sub}${C_RESET}"
}

agent_metric() {
  local label="$1" value="$2" sub="${3:-}"
  jq -nc --arg l "$label" --arg v "$value" --arg s "$sub" \
    '{label:$l, value:$v, sub:$s}'
}

# ============ STEP (USER mode) ============
# Numbered step
# user_step 1 "Scout" "Mapping auth system..."
user_step() {
  [[ "$(get_mode)" != "user" ]] && { agent_step "$@"; return; }
  local num="$1" title="$2" detail="${3:-}"
  echo -e "  ${C_BOLD}${C_CYAN}${num}${C_RESET} ${C_BOLD}${title}${C_RESET}"
  [[ -n "$detail" ]] && echo -e "      ${C_DIM}${detail}${C_RESET}"
}

agent_step() {
  local num="$1" title="$2" detail="${3:-}"
  jq -nc --argjson n "$num" --arg t "$title" --arg d "$detail" \
    '{step:$n, title:$t, detail:$d}'
}

# ============ NEXT (USER mode) ============
# Suggested next action
# user_next "/commit" "Stage and commit" "/review" "Review changes"
user_next() {
  [[ "$(get_mode)" != "user" ]] && { agent_next "$@"; return; }
  while [[ $# -gt 0 ]]; do
    local cmd="$1" desc="$2"
    echo -e "  ${C_DIM}${ICON_ARROW}${C_RESET} ${C_BOLD}${C_CYAN}${cmd}${C_RESET}  ${C_DIM}${desc}${C_RESET}"
    shift 2
  done
}

agent_next() {
  local next=""
  while [[ $# -gt 0 ]]; do
    next+="\"$1\":\"$2\","
    shift 2
  done
  next="${next%,}"
  echo "{\"next\":{$next}}"
}

# ============ HINT (USER mode) ============
# Pro tip
# user_hint "Try /metrics to see session stats"
user_hint() {
  [[ "$(get_mode)" != "user" ]] && return 0
  echo -e "  ${C_YAN}${ICON_INFO}${C_RESET} ${C_DIM}$*${C_RESET}"
}

# ============ DONE (USER mode) ============
# Final summary, success
done_msg() {
  report status=ok "$@"
}

# ============ FAIL (USER mode) ============
# Final summary, failure
fail_msg() {
  report status=fail "$@"
}

# ============ WARN (USER mode) ============
warn_msg() {
  report status=warn "$@"
}

# ============ HEADER (USER mode) ============
# Section header
# user_header "Daily Standup"
user_header() {
  [[ "$(get_mode)" != "user" ]] && { agent_header "$@"; return; }
  local text="$1"
  echo
  echo -e "${C_BOLD}${C_CYAN}━━━ $text ━━━${C_RESET}"
  echo
}

agent_header() {
  local text="$1"
  echo "{\"section\":\"$text\"}"
}

# ============ DIVIDER (USER mode) ============
user_divider() {
  [[ "$(get_mode)" != "user" ]] && return 0
  echo -e "${C_DIM}─────────────────────────────────────────${C_RESET}"
}

# ============ KV (compact key=value for agent) ============
# agent_kv status=ok action=commit hash=abc1234
agent_kv() {
  local out=""
  for arg in "$@"; do
    if [[ -z "$out" ]]; then
      out="$arg"
    else
      out+=" $arg"
    fi
  done
  echo "$out"
}

# ============ FORCE MODE ============
# Use these to force a specific mode for one call
as_user() {
  CEO_MODE_OVERRIDE="user" "$@"
}

as_agent() {
  CEO_MODE_OVERRIDE="agent" "$@"
}

# ============ EXPORT ============
# (No `export -f` — it causes function bodies to be echoed in some shells)
# Functions are available within the current shell after sourcing.
