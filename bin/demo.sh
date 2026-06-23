#!/usr/bin/env bash
# bin/demo.sh — The first-run experience
# Shows what the system can do in 30 seconds. Addictive.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=format.sh
source "$SCRIPT_DIR/format.sh"

clear 2>/dev/null || true

# Hero header
echo
echo -e "${C_BOLD}${C_CYAN}  ╔══════════════════════════════════════════════════════════════╗${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}  ║${C_RESET}                                                              ${C_BOLD}${C_CYAN}║${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}  ║${C_RESET}  ${C_BOLD}CEO Engineering System${C_RESET}  ${C_DIM}— turn into a 10× engineer${C_RESET}        ${C_BOLD}${C_CYAN}║${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}  ║${C_RESET}                                                              ${C_BOLD}${C_CYAN}║${C_RESET}"
echo -e "${C_BOLD}${C_CYAN}  ╚══════════════════════════════════════════════════════════════╝${C_RESET}"
echo

# What you got
user_header "What you got"

cat <<EOF
  ${C_CYAN}${ICON_DOT}${C_RESET} 9 specialist subagents   (scout, architect, builder, reviewer...)
  ${C_CYAN}${ICON_DOT}${C_RESET} 23 daily-work skills      (/commit, /pr, /review, /merge-conflict...)
  ${C_CYAN}${ICON_DOT}${C_RESET} 70+ curated skills        (obra/superpowers, mattpocock, caveman...)
  ${C_CYAN}${ICON_DOT}${C_RESET} 8 efficiency MCPs        (RTK, CodeGraph, Octocode, Caveman...)
  ${C_CYAN}${ICON_DOT}${C_RESET} 5 hook scripts           (block-destructive, format, typecheck...)
  ${C_CYAN}${ICON_DOT}${C_RESET} 3 loop patterns          (Ralph, TDD, persistent)
EOF
echo

# Try this
user_header "Try this — your first 60 seconds"

cat <<EOF
  ${C_BOLD}1.${C_RESET} Switch to the CEO agent
     ${C_DIM}\$ opencode${C_RESET}
     ${C_DIM}> /agent ceo${C_RESET}

  ${C_BOLD}2.${C_RESET} Give it an intent (don't micro-manage)
     ${C_DIM}> Add a /logout endpoint that clears the session cookie${C_RESET}

  ${C_BOLD}3.${C_RESET} Watch it work
     ${C_DIM}CEO ${ICON_ARROW} scout ${ICON_ARROW} architect ${ICON_ARROW} builder ${ICON_ARROW} reviewer+tester ${ICON_ARROW} report${C_RESET}

  ${C_BOLD}4.${C_RESET} Get a CEO-style report
     ${C_DIM}✓ Done. 3 files. 12/12 tests. \$0.42 spent. Ready to commit.${C_RESET}
EOF
echo

# Daily commands
user_header "Daily commands (the ones you'll use most)"

user_next \
  "/commit"       "Stage and commit" \
  "/pr"           "Open a pull request" \
  "/review"       "Review uncommitted changes" \
  "/merge-conflict" "Resolve conflicts" \
  "/metrics"      "Session cost + throughput" \
  "/feature"      "Full feature pipeline"
echo

# Output modes
user_header "Two output modes — same data, different presentation"

cat <<EOF
  ${C_BOLD}USER mode${C_RESET} ${C_DIM}(what you see)${C_RESET}

  ${C_GREEN}${ICON_OK}${C_RESET} ${C_BOLD}Feature complete: Add MFA${C_RESET}
    ${C_DIM}src/auth/login.ts:42-89    added MFA flow${C_RESET}
    ${C_DIM}src/auth/mfa.ts:1-156      new module${C_RESET}
    ${C_DIM}tests/auth/mfa.test.ts     8 new tests${C_RESET}

    ${C_DIM}─────────────────────${C_RESET}
    ${C_DIM}Tests${C_RESET}     12/12 ${C_GREEN}${ICON_OK}${C_RESET}
    ${C_DIM}Cost${C_RESET}      \$0.42
    ${C_DIM}Cache${C_RESET}     78% hit
    ${C_DIM}Time${C_RESET}      4.2s
    ${C_DIM}Model${C_RESET}     minimax-m3
                                          ${C_DIM}${ICON_ARROW} /commit${C_RESET}

  ${C_BOLD}AGENT mode${C_RESET} ${C_DIM}(what subagents read — 70% fewer tokens)${C_RESET}
EOF
echo
echo '  {"status":"ok","action":"feature_complete","target":"add_mfa","files":[{"path":"src/auth/login.ts","lines":"42-89"},{"path":"src/auth/mfa.ts","lines":"1-156"}],"tests":"12/12","cost_usd":0.42,"model":"minimax-m3","next":["commit"]}'
echo

# Stats
user_header "Your setup"

cat <<EOF
  ${C_CYAN}${ICON_DOT}${C_RESET} opencode:    ${C_BOLD}configured${C_RESET} (default agent: ceo)
  ${C_CYAN}${ICON_DOT}${C_RESET} Claude Code: ${C_BOLD}configured${C_RESET} (CLAUDE.md symlinked to AGENTS.md)
  ${C_CYAN}${ICON_DOT}${C_RESET} RTK:         ${C_BOLD}$(command -v rtk >/dev/null && echo "installed (60-90% bash savings)" || echo "not installed — run: brew install rtk && rtk init -g")${C_RESET}
  ${C_CYAN}${ICON_DOT}${C_RESET} Skills:      ${C_BOLD}$(ls ~/.config/opencode/skills/ 2>/dev/null | wc -l | tr -d ' ') installed${C_RESET}
  ${C_CYAN}${ICON_DOT}${C_RESET} Agents:      ${C_BOLD}$(ls ~/.config/opencode/agents/ 2>/dev/null | wc -l | tr -d ' ') installed${C_RESET}
  ${C_CYAN}${ICON_DOT}${C_RESET} MCPs:        ${C_BOLD}$(jq -r '.mcp | keys | length' ~/.config/opencode/opencode.json 2>/dev/null || echo 0) configured${C_RESET}
EOF
echo

# Footer
user_divider
user_hint "Run /metrics anytime to see your session stats"
user_hint "Run /help to see all 23 daily commands"
user_hint "Read docs/architecture.md to understand the system"
echo
echo -e "${C_DIM}Made with ${ICON_FIRE} by the CEO Engineering System${C_RESET}"
echo
