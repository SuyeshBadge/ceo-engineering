#!/usr/bin/env bash
# CEO Engineering System - One-Command Setup
# Installs the CEO agent fleet, skills, hooks, and config for both opencode and Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/setup.sh | bash
#    or: ./setup.sh

set -euo pipefail

REPO_URL="https://github.com/SuyeshBadge/ceo-engineering"
REPO_RAW="https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main"

OC_DIR="$HOME/.config/opencode"
CC_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.config/opencode.backup.$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

log()   { echo -e "${BLUE}▸${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
err()   { echo -e "${RED}✗${NC} $*"; }

# 1. Detect environment
log "Detecting environment..."
echo "  OS: $(uname -s)"
echo "  Shell: $SHELL"
echo "  opencode dir: $OC_DIR"
echo "  Claude Code dir: $CC_DIR"
echo

# Helper: install skills from skills.sh via the npx CLI
install_skills_from_manifest() {
  local target_dir="$1"
  local manifest="skills-manifest.json"
  [[ ! -f "$manifest" ]] && return 0

  if ! command -v npx >/dev/null 2>&1; then
    warn "npx not found — skipping skills.sh install. Run manually with: npx skills add <owner/repo>"
    return 0
  fi

  log "Installing curated skills from skills.sh (see skills-manifest.json)..."

  # Parse manifest and install tier-1 skills
  local count=0
  local failed=0
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    printf "  %-50s " "$repo"
    if npx --yes skills add "$repo" >/dev/null 2>&1; then
      echo -e "${GREEN}✓${NC}"
      ((count++))
    else
      # Try alternative: direct git clone into the right path
      local skill_name=$(basename "$repo")
      local clone_url="https://github.com/$repo"
      local target_skill_dir="$target_dir/skills/$skill_name"
      if [[ -d "$target_skill_dir/SKILL.md" ]]; then
        echo -e "${YELLOW}✓ (cached)${NC}"
        ((count++))
      elif git clone --depth 1 "$clone_url" "$TMP_DIR/skills-clone-$skill_name" >/dev/null 2>&1; then
        # Try to find SKILL.md files and copy them
        if find "$TMP_DIR/skills-clone-$skill_name" -name "SKILL.md" 2>/dev/null | head -1 > /dev/null; then
          echo -e "${YELLOW}⚠ partial (manual install may be needed)${NC}"
        else
          echo -e "${YELLOW}⚠ (no SKILL.md found in repo)${NC}"
        fi
        ((failed++))
      else
        echo -e "${RED}✗ (install manually: npx skills add $repo)${NC}"
        ((failed++))
      fi
    fi
  done < <(jq -r '.categories | to_entries[] | select(.value.install == true) | .value.skills[].name' "$manifest" 2>/dev/null)

  if [[ $count -gt 0 ]]; then
    ok "Installed $count skills from skills.sh"
  fi
  if [[ $failed -gt 0 ]]; then
    warn "$failed skills need manual install. See: https://skills.sh"
    echo "  Manual install: npx skills add <owner/repo>"
  fi
}

# 2. Check for required tools
log "Checking dependencies..."
for tool in curl git jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    err "Missing required tool: $tool"
    echo "  Install with: brew install $tool"
    exit 1
  fi
done
ok "Dependencies OK (curl, git, jq)"
echo

# 3. Backup existing configs
if [[ -d "$OC_DIR" ]] && [[ -f "$OC_DIR/opencode.json" ]]; then
  log "Backing up existing opencode config to $BACKUP_DIR"
  cp -r "$OC_DIR" "$BACKUP_DIR"
  ok "Backup created"
fi
echo

# 4. Detect which editors to set up
SETUP_OPENCODE=false
SETUP_CLAUDE=false

if command -v opencode >/dev/null 2>&1 || [[ -d "$OC_DIR" ]]; then
  SETUP_OPENCODE=true
fi
if command -v claude >/dev/null 2>&1 || [[ -d "$CC_DIR" ]]; then
  SETUP_CLAUDE=true
fi

if [[ "$SETUP_OPENCODE" == false ]] && [[ "$SETUP_CLAUDE" == false ]]; then
  warn "Neither opencode nor Claude Code detected."
  echo "  Install one of them first:"
  echo "    opencode:  https://opencode.ai/docs/"
  echo "    Claude:    https://claude.com/product/claude-code"
  echo
  read -p "Continue anyway and set up configs for future installs? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
  fi
  SETUP_OPENCODE=true
  SETUP_CLAUDE=true
fi

log "Will set up: $([ "$SETUP_OPENCODE" == true ] && echo "opencode" || echo "") $([ "$SETUP_CLAUDE" == true ] && echo "Claude Code" || echo "")"
echo

# 5. Create directories
log "Creating directories..."
mkdir -p "$OC_DIR/agents" "$OC_DIR/skills" "$OC_DIR/plugins" "$OC_DIR/hooks" "$OC_DIR/loops"
mkdir -p "$CC_DIR/agents" "$CC_DIR/skills" "$CC_DIR/hooks"
ok "Directories created"
echo

# 6. Download and install
log "Downloading CEO Engineering System..."

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

if [[ -d ".git" ]] && [[ -f "./setup.sh" ]]; then
  log "Installing from local clone..."
  cp -r ./* "$TMP_DIR/" 2>/dev/null || true
else
  log "Cloning from $REPO_URL..."
  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo" 2>/dev/null || {
    err "Failed to clone repo. Check your internet connection."
    exit 1
  }
  cp -r "$TMP_DIR/repo"/* "$TMP_DIR/"
fi

cd "$TMP_DIR"
ok "Downloaded"
echo

# 6.5. Install RTK (Rust Token Killer) — biggest token savings win
if command -v brew >/dev/null 2>&1; then
  if ! command -v rtk >/dev/null 2>&1; then
    log "Installing RTK (Rust Token Killer) — 60-90% bash savings..."
    if brew install rtk 2>/dev/null; then
      ok "RTK installed"
    else
      warn "RTK install via brew failed — install manually: https://github.com/rtk-ai/rtk"
    fi
  else
    ok "RTK already installed"
  fi
fi

# Initialize RTK hook for whichever editors we found
if command -v rtk >/dev/null 2>&1; then
  if [[ "$SETUP_OPENCODE" == true ]]; then
    rtk init -g --opencode 2>/dev/null && ok "RTK opencode hook installed" || warn "RTK opencode hook failed"
  fi
  if [[ "$SETUP_CLAUDE" == true ]]; then
    rtk init -g 2>/dev/null && ok "RTK Claude Code hook installed" || warn "RTK Claude Code hook failed"
  fi
  echo
fi

# 7. Install opencode config
if [[ "$SETUP_OPENCODE" == true ]]; then
  log "Installing opencode config..."

  # Master rules (preserving CodeGraph if present)
  if [[ -f "$OC_DIR/AGENTS.md" ]]; then
    if ! grep -q "CodeGraph" "$OC_DIR/AGENTS.md" 2>/dev/null; then
      log "Existing AGENTS.md found, appending CEO rules..."
      echo "" >> "$OC_DIR/AGENTS.md"
      cat config/AGENTS.md >> "$OC_DIR/AGENTS.md"
    else
      log "CodeGraph detected in existing AGENTS.md, preserving it..."
      echo "" > "$OC_DIR/AGENTS.md.new"
      cat config/AGENTS.md >> "$OC_DIR/AGENTS.md.new"
      # Preserve CodeGraph block
      awk '/<!-- CODEGRAPH_START -->/,/<!-- CODEGRAPH_END -->/' "$OC_DIR/AGENTS.md" >> "$OC_DIR/AGENTS.md.new"
      mv "$OC_DIR/AGENTS.md.new" "$OC_DIR/AGENTS.md"
    fi
  else
    cp config/AGENTS.md "$OC_DIR/AGENTS.md"
  fi
  ok "AGENTS.md installed"

  # Merge opencode.json (preserve existing MCP/agents)
  if [[ -f "$OC_DIR/opencode.json" ]]; then
    log "Merging opencode.json with existing config..."
    # Backup and merge
    cp "$OC_DIR/opencode.json" "$OC_DIR/opencode.json.bak"
    # Use jq to merge - existing wins on conflicts
    jq -s '.[0] * .[1]' "$OC_DIR/opencode.json" config/opencode.json > "$OC_DIR/opencode.json.merged" 2>/dev/null || {
      warn "jq merge failed, falling back to manual merge"
      cp config/opencode.json "$OC_DIR/opencode.json"
    }
    [[ -f "$OC_DIR/opencode.json.merged" ]] && mv "$OC_DIR/opencode.json.merged" "$OC_DIR/opencode.json"
  else
    cp config/opencode.json "$OC_DIR/opencode.json"
  fi
  ok "opencode.json installed"

  # Agents
  log "Installing opencode agents..."
  cp agents/*.md "$OC_DIR/agents/"
  ok "9 agents installed"

  # Skills
  log "Installing opencode skills..."
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$OC_DIR/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$OC_DIR/skills/$skill_name/"
  done
  ok "23 local skills installed"

  # Skills from skills.sh (curated)
  install_skills_from_manifest "$OC_DIR"

  # Hooks
  log "Installing hook scripts..."
  cp hooks/*.sh "$OC_DIR/hooks/"
  chmod +x "$OC_DIR/hooks/"*.sh
  ok "Hooks installed"

  # Loops
  log "Installing loop scripts..."
  cp loops/*.sh "$OC_DIR/loops/"
  chmod +x "$OC_DIR/loops/"*.sh
  ok "Loops installed"

  echo
fi

# 8. Install Claude Code config
if [[ "$SETUP_CLAUDE" == true ]]; then
  log "Installing Claude Code config..."

  # Symlink AGENTS.md → CLAUDE.md
  if [[ -f "$OC_DIR/AGENTS.md" ]] && [[ ! -L "$CC_DIR/CLAUDE.md" ]]; then
    ln -sf "$OC_DIR/AGENTS.md" "$CC_DIR/CLAUDE.md"
    ok "CLAUDE.md → AGENTS.md symlink created"
  fi

  # Claude Code agents (different frontmatter schema)
  log "Installing Claude Code agents..."
  for agent_file in agents/*.md; do
    agent_name=$(basename "$agent_file" .md)
    # Convert opencode frontmatter to Claude Code format
    # (we ship both formats; CC version lives in agents-cc/)
    if [[ -f "agents-cc/$agent_name.md" ]]; then
      cp "agents-cc/$agent_name.md" "$CC_DIR/agents/$agent_name.md"
    else
      # Fallback: symlink to opencode version (most fields work)
      ln -sf "$OC_DIR/agents/$agent_name.md" "$CC_DIR/agents/$agent_name.md"
    fi
  done
  ok "Claude Code agents installed"

  # Skills (symlink to opencode - Agent Skills standard)
  log "Symlinking skills to Claude Code..."
  for skill_dir in "$OC_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    [[ -L "$CC_DIR/skills/$skill_name" ]] && continue
    ln -sf "$skill_dir" "$CC_DIR/skills/$skill_name"
  done
  ok "Skills symlinked"

  # Hooks
  log "Installing Claude Code settings.json with hooks..."
  if [[ -f "$CC_DIR/settings.json" ]]; then
    # Merge settings, preserving user allowlist
    if command -v jq >/dev/null 2>&1; then
      jq -s '.[0] * .[1]' "$CC_DIR/settings.json" config/settings.json > "$CC_DIR/settings.json.new" 2>/dev/null || {
        cp config/settings.json "$CC_DIR/settings.json"
      }
      [[ -f "$CC_DIR/settings.json.new" ]] && mv "$CC_DIR/settings.json.new" "$CC_DIR/settings.json"
    else
      cp config/settings.json "$CC_DIR/settings.json"
    fi
  else
    cp config/settings.json "$CC_DIR/settings.json"
  fi
  cp hooks/*.sh "$CC_DIR/hooks/" 2>/dev/null || cp "$OC_DIR/hooks/"*.sh "$CC_DIR/hooks/"
  chmod +x "$CC_DIR/hooks/"*.sh
  ok "Claude Code config installed"
  echo
fi

# 9. Verify
log "Verifying installation..."
echo "  opencode agents: $(ls -1 "$OC_DIR/agents" 2>/dev/null | wc -l | tr -d ' ')"
echo "  opencode skills: $(ls -1 "$OC_DIR/skills" 2>/dev/null | wc -l | tr -d ' ')"
echo "  hooks: $(ls -1 "$OC_DIR/hooks" 2>/dev/null | wc -l | tr -d ' ')"
echo "  loops: $(ls -1 "$OC_DIR/loops" 2>/dev/null | wc -l | tr -d ' ')"

# Show skills from skills.sh
if [[ -f "skills-manifest.json" ]] && command -v jq >/dev/null 2>&1; then
  local_count=$(jq -r '.categories | to_entries[] | select(.value.install == true) | .value.skills[].name' skills-manifest.json 2>/dev/null | wc -l | tr -d ' ')
  echo "  skills.sh repos: $local_count (see skills-manifest.json)"
fi
echo

# 10. Done
ok "CEO Engineering System installed!"
echo
echo -e "${GREEN}─────────────────────────────────────────────${NC}"
echo -e "${GREEN}  Next steps:${NC}"
echo -e "${GREEN}─────────────────────────────────────────────${NC}"
echo
echo "  1. Restart opencode / Claude Code (or start a new session)"
echo "  2. Try a daily command:"
echo "     /commit      - conventional commit"
echo "     /pr          - open a pull request"
echo "     /review      - review uncommitted changes"
echo "     /pr-review   - review a PR by URL"
echo "     /merge-conflict - resolve merge conflicts"
echo "     /test        - run targeted tests"
echo
echo "  3. Switch to the ceo agent (the orchestrator):"
echo "     In opencode: type /agent ceo"
echo "     Or set as default in ~/.config/opencode/opencode.json"
echo
echo "  4. Skills from skills.sh are auto-installed."
echo "     Customize by editing skills-manifest.json then re-running setup."
echo
echo "  5. Read the docs:"
echo "     docs/architecture.md          - the full system design"
echo "     docs/commands.md              - all daily commands"
echo "     docs/agent-matrix.md          - what each agent does"
echo "     docs/skills-from-skills-sh.md - curated skills.sh skills"
echo "     docs/efficiency-mcps.md       - RTK, Octocode, Caveman"
echo
echo -e "${YELLOW}To uninstall:${NC} ./uninstall.sh"
echo
