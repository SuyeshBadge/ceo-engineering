#!/usr/bin/env bash
# CEO Engineering System - One-Command Setup
# Installs EVERYTHING: agents, skills, hooks, MCPs, plugins, RTK, codegraph, agent-browser, Chrome.
# Idempotent — safe to re-run. Detects what's missing, installs only gaps.
# Usage: curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/setup.sh | bash
#    or: ./setup.sh [--update] [--skip-rtk] [--skip-mcp] [--skip-chrome]

set -euo pipefail

REPO_URL="https://github.com/SuyeshBadge/ceo-engineering"
REPO_RAW="https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main"

OC_DIR="$HOME/.config/opencode"
CC_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.config/opencode.backup.$(date +%Y%m%d-%H%M%S)"

SKIP_RTK=0
SKIP_MCP=0
SKIP_CHROME=0
for arg in "$@"; do
  case "$arg" in
    --update) ;;  # alias for idempotent re-run
    --skip-rtk) SKIP_RTK=1 ;;
    --skip-mcp) SKIP_MCP=1 ;;
    --skip-chrome) SKIP_CHROME=1 ;;
    --help|-h)
      echo "Usage: setup.sh [--skip-rtk] [--skip-mcp] [--skip-chrome]"
      echo "  Idempotent: re-run anytime to fill gaps."
      exit 0
      ;;
  esac
done

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${BLUE}▸${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*"; }
hdr()  { echo -e "\n${BOLD}── $* ──${NC}"; }

step() {
  local name="$1"; shift
  if "$@" >/tmp/ceo-step.log 2>&1; then
    ok "$name"
  else
    local code=$?
    err "$name (exit $code)"
    sed 's/^/    /' /tmp/ceo-step.log | head -10
    return $code
  fi
}

need() { command -v "$1" >/dev/null 2>&1; }

# ─── 1. Banner ────────────────────────────────────────────────────────────
echo -e "${BOLD}"
echo "  ╭───────────────────────────────────────────────╮"
echo "  │   CEO Engineering System — One-Command Setup  │"
echo "  ╰───────────────────────────────────────────────╯"
echo -e "${NC}"

# ─── 2. OS / shell ────────────────────────────────────────────────────────
log "OS:     $(uname -s) $(uname -m)"
log "Shell:  ${SHELL:-unknown}"
log "Home:   $HOME"
log "opencode: ${OC_DIR}"
log "Claude:   ${CC_DIR}"
echo

# ─── 3. Required tools ────────────────────────────────────────────────────
hdr "1/9 — Required tools"
for tool in curl git jq npm; do
  if need "$tool"; then
    ok "$tool: $(command -v "$tool")"
  else
    err "Missing required tool: $tool"
    echo "  Install with: brew install $tool"
    exit 1
  fi
done

# ─── 4. Backup ────────────────────────────────────────────────────────────
hdr "2/9 — Backup"
if [[ -d "$OC_DIR" ]] && [[ -f "$OC_DIR/opencode.json" ]]; then
  log "Backing up to $BACKUP_DIR"
  cp -r "$OC_DIR" "$BACKUP_DIR"
  ok "Backup created"
else
  log "No existing opencode config — fresh install"
fi
echo

# ─── 5. Download repo ─────────────────────────────────────────────────────
hdr "3/9 — Download CEO Engineering System"
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

if [[ -d ".git" ]] && [[ -f "./setup.sh" ]]; then
  log "Installing from local clone: $(pwd)"
  cp -r . "$TMP_DIR/"
else
  log "Cloning from $REPO_URL ..."
  if ! git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo" 2>/dev/null; then
    err "Clone failed — check internet"
    exit 1
  fi
  cp -r "$TMP_DIR/repo"/. "$TMP_DIR/"
fi
cd "$TMP_DIR"
ok "Repo ready: $(git rev-parse --short HEAD 2>/dev/null || echo 'local')"
echo

# ─── 6. RTK (Rust Token Killer) ───────────────────────────────────────────
hdr "4/9 — RTK (Rust Token Killer)"
if [[ $SKIP_RTK -eq 0 ]]; then
  if need rtk; then
    ok "rtk already installed: $(rtk --version 2>/dev/null | head -1)"
  else
    log "Installing rtk via npm..."
    if npm install -g rtk >/dev/null 2>&1; then
      ok "rtk installed"
    else
      warn "rtk npm install failed — trying brew"
      if need brew; then
        brew install rtk >/dev/null 2>&1 && ok "rtk installed (brew)" || warn "rtk install failed (continuing)"
      else
        warn "rtk install failed (continuing without it)"
      fi
    fi
  fi
  # Wire rtk opencode hook
  if need rtk; then
    rtk init -g --opencode >/dev/null 2>&1 && ok "rtk opencode hook wired" || warn "rtk opencode hook failed"
    rtk init -g >/dev/null 2>&1 && ok "rtk claude-code hook wired" || warn "rtk claude-code hook skipped"
  fi
else
  log "skipped (--skip-rtk)"
fi
echo

# ─── 7. codegraph (knowledge graph for any codebase) ──────────────────────
hdr "5/9 — codegraph"
if need codegraph; then
  ok "codegraph: $(codegraph --version 2>/dev/null | head -1)"
else
  log "Installing codegraph via npm..."
  if npm install -g @colbymchenry/codegraph >/dev/null 2>&1; then
    ok "codegraph installed"
  else
    warn "codegraph npm install failed — install manually: https://www.npmjs.com/package/@colbymchenry/codegraph"
  fi
fi
echo

# ─── 8. agent-browser (Vercel Labs) + Chrome ──────────────────────────────
hdr "6/9 — agent-browser (Vercel Labs)"
if need agent-browser; then
  AB_VER=$(agent-browser --version 2>/dev/null | head -1)
  ok "agent-browser: $AB_VER"
  if [[ $SKIP_CHROME -eq 0 ]] && ! agent-browser doctor 2>/dev/null | grep -q "Launch test.*pass"; then
    log "Chrome missing — running 'agent-browser install'..."
    agent-browser install >/dev/null 2>&1 && ok "Chrome installed" || warn "Chrome install failed (run 'agent-browser install' manually)"
  fi
else
  log "Installing agent-browser via npm..."
  if npm install -g agent-browser >/dev/null 2>&1; then
    ok "agent-browser installed"
    if [[ $SKIP_CHROME -eq 0 ]]; then
      log "Downloading Chrome for Testing (first run)..."
      agent-browser install >/dev/null 2>&1 && ok "Chrome downloaded" || warn "Chrome download failed (run 'agent-browser install' manually)"
    fi
  else
    warn "agent-browser install failed — install manually: https://www.npmjs.com/package/agent-browser"
  fi
fi
echo

# ─── 9. opencode dirs + agents + commands + skills + hooks + loops + bin ─
hdr "7/9 — opencode config"
mkdir -p "$OC_DIR"/{agents,commands,skills,plugins,hooks,loops,bin,logs}

if [[ -d agents ]]; then
  log "Installing 9 agents..."
  cp agents/*.md "$OC_DIR/agents/"
  ok "9 agents installed"
fi

# Commands (/commit, /test, /pr, ...) — opencode reads from commands/<name>.md
if [[ -d commands ]]; then
  log "Installing slash commands..."
  cmd_count=0
  for cmd_dir in commands/*/; do
    [[ ! -d "$cmd_dir" ]] && continue
    cmd_name=$(basename "$cmd_dir")
    [[ -f "$cmd_dir/SKILL.md" ]] || continue
    cp "$cmd_dir/SKILL.md" "$OC_DIR/commands/$cmd_name.md"
    ((cmd_count++))
  done
  ok "$cmd_count slash commands installed"
fi

# Agent skills (reference material loaded by the skill tool)
if [[ -d skills ]]; then
  log "Installing agent skills..."
  skill_count=0
  for skill_dir in skills/*/; do
    [[ ! -d "$skill_dir" ]] && continue
    skill_name=$(basename "$skill_dir")
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    mkdir -p "$OC_DIR/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$OC_DIR/skills/$skill_name/"
    ((skill_count++))
  done
  ok "$skill_count agent skills installed"
fi

if [[ -d hooks ]]; then
  log "Installing hook scripts..."
  cp hooks/*.sh "$OC_DIR/hooks/"
  chmod +x "$OC_DIR/hooks/"*.sh
  ok "5 hooks installed"
fi

if [[ -d loops ]]; then
  log "Installing loop scripts..."
  cp loops/*.sh "$OC_DIR/loops/"
  chmod +x "$OC_DIR/loops/"*.sh
  ok "3 loops installed"
fi

if [[ -d bin ]]; then
  log "Installing bin scripts (output format library)..."
  cp bin/*.sh "$OC_DIR/bin/"
  chmod +x "$OC_DIR/bin/"*.sh
  ok "4 bin scripts installed"
fi

# AGENTS.md (master rules; preserves user's CodeGraph block; never duplicates)
if [[ -f config/AGENTS.md ]]; then
  if [[ -f "$OC_DIR/AGENTS.md" ]] && grep -q "CEO Engineering System\|CEO's Chief of Staff" "$OC_DIR/AGENTS.md" 2>/dev/null; then
    # Existing AGENTS.md already has the CEO rules — preserve any user codegraph block, replace CEO section
    log "AGENTS.md already has CEO rules — preserving user's CodeGraph block, refreshing rules"
    if grep -q "CodeGraph" "$OC_DIR/AGENTS.md" 2>/dev/null; then
      awk '/<!-- CODEGRAPH_START -->/,/<!-- CODEGRAPH_END -->/' "$OC_DIR/AGENTS.md" > /tmp/cg-block.md
      cp config/AGENTS.md "$OC_DIR/AGENTS.md"
      echo "" >> "$OC_DIR/AGENTS.md"
      cat /tmp/cg-block.md >> "$OC_DIR/AGENTS.md"
    else
      cp config/AGENTS.md "$OC_DIR/AGENTS.md"
    fi
  else
    # No existing CEO rules, or no AGENTS.md — overwrite cleanly
    log "Installing AGENTS.md (CEO constitution)"
    if [[ -f "$OC_DIR/AGENTS.md" ]] && grep -q "CodeGraph" "$OC_DIR/AGENTS.md" 2>/dev/null; then
      awk '/<!-- CODEGRAPH_START -->/,/<!-- CODEGRAPH_END -->/' "$OC_DIR/AGENTS.md" > /tmp/cg-block.md
      cp config/AGENTS.md "$OC_DIR/AGENTS.md"
      echo "" >> "$OC_DIR/AGENTS.md"
      cat /tmp/cg-block.md >> "$OC_DIR/AGENTS.md"
    else
      cp config/AGENTS.md "$OC_DIR/AGENTS.md"
    fi
  fi
  ok "AGENTS.md installed"
fi

# safety-hooks plugin (wires hooks/*.sh into opencode's tool/session events)
if [[ -f plugins/safety-hooks.ts ]]; then
  cp plugins/safety-hooks.ts "$OC_DIR/plugins/safety-hooks.ts"
  ok "safety-hooks plugin installed"
fi
echo

# ─── 10. opencode.json: install base + merge MCPs ─────────────────────────
hdr "8/9 — opencode.json + MCPs"
cp config/opencode.json "$OC_DIR/opencode.json.bak" 2>/dev/null || true
cp config/opencode.json "$OC_DIR/opencode.json"
ok "opencode.json base installed"

if [[ $SKIP_MCP -eq 0 ]] && [[ -f config/mcp.json ]] && need jq; then
  log "Merging efficiency MCPs (codegraph, context7, octocode, gh-grep, agent-browser, filesystem)..."
  local_mcps=$(jq '.mcp // {} | with_entries(select(.key | startswith("_") | not))' config/mcp.json 2>/dev/null || echo "{}")
  existing_mcps=$(jq '.mcp // {} | with_entries(select(.key | startswith("_") | not))' "$OC_DIR/opencode.json" 2>/dev/null || echo "{}")
  merged_mcps=$(jq -n --argjson a "$existing_mcps" --argjson b "$local_mcps" '$a * $b')
  jq --argjson m "$merged_mcps" '.mcp = $m' "$OC_DIR/opencode.json" > "$OC_DIR/opencode.json.tmp" && mv "$OC_DIR/opencode.json.tmp" "$OC_DIR/opencode.json"
  ok "Efficiency MCPs merged"
else
  warn "MCPs skipped (--skip-mcp or jq/mcp.json missing)"
fi
echo

# ─── 11. Curated skills from skills.sh ────────────────────────────────────
hdr "9/9 — Curated skills from skills.sh"
install_skills_from_manifest() {
  [[ -f skills-manifest.json ]] || return 0
  need npx || { warn "npx missing — skipping skills.sh install"; return 0; }

  local ok_count=0 fail_count=0

  # 1) Bundled skills (ship with the repo, no skills.sh install)
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local name=$(echo "$line" | cut -f1)
    local path=$(echo "$line" | cut -f2)
    printf "  [bundled] %-30s " "$name"
    if [[ -f "$path" ]]; then
      local skill_dir="$OC_DIR/skills/$name"
      mkdir -p "$skill_dir"
      cp "$path" "$skill_dir/SKILL.md"
      echo -e "${GREEN}✓${NC}"
      ((ok_count++))
    else
      echo -e "${RED}✗ not found: $path${NC}"
      ((fail_count++))
    fi
  done < <(jq -r '.categories | to_entries[] | select(.value.bundled == true and .value.install == true) | .value.skills[] | "\(.name)\t\(.path)"' skills-manifest.json 2>/dev/null)

  # 2) Skills with binary deps (install binary if missing, then skill)
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local name=$(echo "$line" | cut -f1)
    local binary=$(echo "$line" | cut -f2)
    local hint=$(echo "$line" | cut -f3-)
    printf "  [binary]  %-30s " "$name"
    if need "$binary"; then
      echo -e "${GREEN}✓ ($binary present)${NC}"
      ((ok_count++))
    else
      echo -e "${YELLOW}⚠ run: $hint${NC}"
      ((fail_count++))
    fi
  done < <(jq -r '.categories | to_entries[] | select(.value.install == true) | .value.skills[] | select(.binary != null) | "\(.name)\t\(.binary)\t\(.install_hint // "")"' skills-manifest.json 2>/dev/null)

  # 3) skills.sh repos
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    printf "  [skills.sh] %-26s " "$repo"
    if npx --yes skills add "$repo" >/dev/null 2>&1; then
      echo -e "${GREEN}✓${NC}"
      ((ok_count++))
    else
      echo -e "${YELLOW}⚠ manual: npx skills add $repo${NC}"
      ((fail_count++))
    fi
  done < <(jq -r '.categories | to_entries[] | select(.value.bundled != true and .value.install == true) | .value.skills[] | select(.binary == null) | .name' skills-manifest.json 2>/dev/null)

  ok "$ok_count ready, $fail_count need manual install (see above)"
}
install_skills_from_manifest
echo

# ─── 12. Claude Code config (optional) ────────────────────────────────────
if [[ -d "$CC_DIR" ]] || need claude; then
  hdr "Claude Code (optional)"
  mkdir -p "$CC_DIR/agents" "$CC_DIR/commands" "$CC_DIR/skills" "$CC_DIR/hooks"
  # Symlink AGENTS.md → CLAUDE.md
  if [[ -f "$OC_DIR/AGENTS.md" ]] && [[ ! -L "$CC_DIR/CLAUDE.md" ]]; then
    ln -sf "$OC_DIR/AGENTS.md" "$CC_DIR/CLAUDE.md"
    ok "CLAUDE.md → AGENTS.md"
  fi
  # CC-specific agents
  if [[ -d agents-cc ]]; then
    for f in agents-cc/*.md; do
      [[ -f "$f" ]] && cp "$f" "$CC_DIR/agents/$(basename "$f")"
    done
    ok "Claude Code agents installed"
  fi
  # Slash commands (Claude Code reads from commands/<name>.md — same as opencode)
  if [[ -d commands ]]; then
    cc_cmd_count=0
    for cmd_dir in commands/*/; do
      [[ ! -d "$cmd_dir" ]] && continue
      cmd_name=$(basename "$cmd_dir")
      [[ -f "$cmd_dir/SKILL.md" ]] || continue
      cp "$cmd_dir/SKILL.md" "$CC_DIR/commands/$cmd_name.md"
      ((cc_cmd_count++))
    done
    ok "$cc_cmd_count slash commands installed for Claude Code"
  fi
  # Symlink skills
  for skill_dir in "$OC_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    [[ -L "$CC_DIR/skills/$skill_name" ]] && continue
    ln -sf "$skill_dir" "$CC_DIR/skills/$skill_name"
  done
  ok "Skills symlinked to Claude Code"
  # Settings + hooks
  if [[ -f config/settings.json ]]; then
    if [[ -f "$CC_DIR/settings.json" ]] && need jq; then
      jq -s '.[0] * .[1]' "$CC_DIR/settings.json" config/settings.json > "$CC_DIR/settings.json.new" 2>/dev/null \
        && mv "$CC_DIR/settings.json.new" "$CC_DIR/settings.json" \
        || cp config/settings.json "$CC_DIR/settings.json"
    else
      cp config/settings.json "$CC_DIR/settings.json"
    fi
    ok "Claude Code settings + hooks installed"
  fi
  cp hooks/*.sh "$CC_DIR/hooks/" 2>/dev/null && chmod +x "$CC_DIR/hooks/"*.sh
  ok "Claude Code hook scripts installed"
  echo
fi

# ─── 13. Verify ───────────────────────────────────────────────────────────
hdr "Verify"
echo "  opencode agents:    $(ls -1 "$OC_DIR/agents" 2>/dev/null | wc -l | tr -d ' ')"
echo "  opencode commands:  $(ls -1 "$OC_DIR/commands" 2>/dev/null | wc -l | tr -d ' ') (/commit, /test, /pr, ...)"
echo "  opencode skills:    $(ls -1 "$OC_DIR/skills" 2>/dev/null | wc -l | tr -d ' ')"
echo "  hooks:              $(ls -1 "$OC_DIR/hooks" 2>/dev/null | wc -l | tr -d ' ')"
echo "  loops:              $(ls -1 "$OC_DIR/loops" 2>/dev/null | wc -l | tr -d ' ')"
echo "  plugins:            $(ls -1 "$OC_DIR/plugins" 2>/dev/null | wc -l | tr -d ' ')"
echo "  bin:                $(ls -1 "$OC_DIR/bin" 2>/dev/null | wc -l | tr -d ' ')"
if [[ -d "$CC_DIR" ]]; then
  echo "  Claude Code cmds:   $(ls -1 "$CC_DIR/commands" 2>/dev/null | wc -l | tr -d ' ')"
  echo "  Claude Code skills: $(ls -1 "$CC_DIR/skills" 2>/dev/null | wc -l | tr -d ' ')"
fi

echo
echo "  Tooling:"
need rtk             && echo "    rtk:        $(rtk --version 2>/dev/null | head -1)" || echo "    rtk:        MISSING"
need codegraph       && echo "    codegraph:  present"                                                  || echo "    codegraph:  MISSING"
need agent-browser   && echo "    agent-browser: $(agent-browser --version 2>/dev/null | head -1)"  || echo "    agent-browser: MISSING"

if need opencode; then
  echo
  log "opencode MCP servers:"
  opencode mcp list 2>/dev/null | grep -E "✓|✗|○" | sed 's/^/    /' || warn "opencode mcp list failed"
fi
echo

# ─── 14. Done ─────────────────────────────────────────────────────────────
ok "CEO Engineering System ready!"
echo
echo -e "${BOLD}  Next steps:${NC}"
echo "    1. Restart opencode (or start a new session) to load plugins/MCPs."
echo "    2. /agent ceo        — switch to the CEO orchestrator"
echo "    3. /feature \"...\"    — full pipeline (scout → architect → builder → reviewer → tester)"
echo "    4. /commit /pr /review /test  — daily skills"
echo
echo -e "  ${YELLOW}Re-run this script anytime to fill gaps. Use --skip-rtk/--skip-mcp/--skip-chrome to opt out.${NC}"
echo
echo -e "  ${YELLOW}Uninstall:${NC} curl -fsSL $REPO_RAW/uninstall.sh | bash"
echo
