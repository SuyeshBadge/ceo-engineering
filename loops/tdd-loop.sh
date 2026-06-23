#!/usr/bin/env bash
# TDD loop: write failing test → make it pass → refactor → repeat
# Usage: tdd-loop.sh "description of behavior to implement"

set -euo pipefail

DESC="${1:-}"

[[ -z "$DESC" ]] && { echo "Usage: tdd-loop.sh <behavior description>"; exit 1; }

LOG_DIR="${CEO_LOGS:-$HOME/.config/opencode/logs}"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/tdd-$(date +%Y%m%d-%H%M%S).log"

PROMPT=$(cat <<EOF
You are in a strict TDD loop. The user wants this behavior:
---
$DESC
---

Cycle:
1. RED    — write a single failing test that demonstrates the desired behavior. Run it. Confirm it fails.
2. GREEN  — write the minimum code to make that test pass. Run it. Confirm green.
3. REFACTOR — clean up without breaking the test. Run it. Confirm still green.
4. COMMIT — \`git add -A && git commit -m "test: <behavior>"\`

If you have more behavior to add, repeat. When all behavior is implemented, output "DONE".

Rules:
- ONE test at a time. Don't write multiple.
- Don't write code before the test exists.
- Don't refactor during RED or GREEN phases.
- Run the actual test command (detect from package.json / pyproject.toml / go.mod).
EOF
)

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  TDD Loop: $DESC"
echo "╚════════════════════════════════════════════════════════════╝"
echo

cat <<< "$PROMPT" | opencode run --non-interactive 2>&1 | tee -a "$LOG"
echo
echo "TDD loop log: $LOG"
