#!/usr/bin/env bash
# bin/present.sh — Presentation wrapper
# Wraps any output to be in the right format for the audience.
#
# Usage:
#   bin/present.sh user <command>     # force user mode
#   bin/present.sh agent <command>    # force agent mode (compact)
#   bin/present.sh auto <command>     # auto-detect mode
#
# Examples:
#   bin/present.sh user git log --oneline -5
#   bin/present.sh agent cat file.json | jq

set -euo pipefail

MODE="${1:-auto}"
shift || true

case "$MODE" in
  user)
    CEO_MODE_OVERRIDE="user" "$@"
    ;;
  agent)
    CEO_MODE_OVERRIDE="agent" "$@"
    ;;
  auto)
    "$@"
    ;;
  *)
    echo "Usage: $0 {user|agent|auto} <command> [args...]" >&2
    exit 1
    ;;
esac
