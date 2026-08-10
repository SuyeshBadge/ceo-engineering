#!/usr/bin/env bash
# Install the ceo-engineering opencode setup into this machine.
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/install.sh | bash
set -euo pipefail

REPO_URL="https://github.com/SuyeshBadge/ceo-engineering.git"
TARGET_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required to install this setup" >&2
  exit 1
fi

echo "Cloning $REPO_URL..."
git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR/repo"
rm -rf "$TMP_DIR/repo/.git"

if [ -d "$TARGET_DIR" ]; then
  BACKUP_DIR="${TARGET_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing config: $TARGET_DIR -> $BACKUP_DIR"
  cp -R "$TARGET_DIR" "$BACKUP_DIR"
fi

mkdir -p "$TARGET_DIR"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude 'install.sh' "$TMP_DIR/repo/" "$TARGET_DIR/"
else
  find "$TMP_DIR/repo" -mindepth 1 -maxdepth 1 -not -name 'install.sh' -exec cp -R {} "$TARGET_DIR/" \;
fi

chmod +x "$TARGET_DIR"/bin/*.sh 2>/dev/null || true
chmod +x "$TARGET_DIR"/hooks/*.sh 2>/dev/null || true
chmod +x "$TARGET_DIR"/loops/*.sh 2>/dev/null || true

echo "Installed opencode setup to $TARGET_DIR"
