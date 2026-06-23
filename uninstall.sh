#!/usr/bin/env bash
# CEO Engineering System - Uninstaller
# Removes all installed files and restores backup if present

set -euo pipefail

OC_DIR="$HOME/.config/opencode"
CC_DIR="$HOME/.claude"
BACKUP_DIR=""

# Find most recent backup
if ls -d "$HOME"/.config/opencode.backup.* 2>/dev/null | head -1 > /dev/null; then
  BACKUP_DIR=$(ls -td "$HOME"/.config/opencode.backup.* | head -1)
fi

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }

warn "This will remove all CEO Engineering System files."
echo
if [[ -n "$BACKUP_DIR" ]]; then
  echo "Found backup of original opencode config: $BACKUP_DIR"
  echo "This will be restored."
else
  echo "No backup found. Original opencode.json (if any) will be preserved as opencode.json.bak"
fi
echo
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 0
fi

# Remove CEO files
warn "Removing CEO files..."
[[ -f "$OC_DIR/AGENTS.md" ]] && rm -f "$OC_DIR/AGENTS.md"
[[ -d "$OC_DIR/agents" ]] && rm -rf "$OC_DIR/agents/ceo.md" "$OC_DIR/agents/scout.md" "$OC_DIR/agents/architect.md" "$OC_DIR/agents/builder.md" "$OC_DIR/agents/reviewer.md" "$OC_DIR/agents/tester.md" "$OC_DIR/agents/security.md" "$OC_DIR/agents/doc-writer.md" "$OC_DIR/agents/devops.md" 2>/dev/null || true

# Remove skills
for skill in commit pr review pr-review merge-conflict test format lint typecheck branch sync explain doc changelog release hotfix clean feature bug refactor security mvp metrics; do
  [[ -d "$OC_DIR/skills/$skill" ]] && rm -rf "$OC_DIR/skills/$skill"
done

[[ -d "$OC_DIR/hooks" ]] && rm -rf "$OC_DIR/hooks"
[[ -d "$OC_DIR/loops" ]] && rm -rf "$OC_DIR/loops"
ok "Removed opencode files"

# Remove Claude Code symlinks
[[ -L "$CC_DIR/CLAUDE.md" ]] && rm -f "$CC_DIR/CLAUDE.md"
for skill in commit pr review pr-review merge-conflict test format lint typecheck branch sync explain doc changelog release hotfix clean feature bug refactor security mvp metrics; do
  [[ -L "$CC_DIR/skills/$skill" ]] && rm -f "$CC_DIR/skills/$skill"
done
ok "Removed Claude Code files"

# Restore backup
if [[ -n "$BACKUP_DIR" ]] && [[ -d "$BACKUP_DIR" ]]; then
  warn "Restoring backup from $BACKUP_DIR..."
  rm -rf "$OC_DIR"
  cp -r "$BACKUP_DIR" "$OC_DIR"
  ok "Backup restored"
else
  warn "No backup to restore. OpenCode config preserved (opencode.json.bak if it exists)."
fi

echo
ok "Uninstall complete."
