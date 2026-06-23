---
name: changelog
description: Update CHANGELOG.md with recent merged changes. Use before a release.
disable-model-invocation: true
allowed-tools: Bash(git:*), Read, Edit, Write
---

## Commits since last tag
!`git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --oneline`

## Existing CHANGELOG
!`ls CHANGELOG.md 2>/dev/null && head -50 CHANGELOG.md || echo "no CHANGELOG.md"`

## Instructions

1. If no CHANGELOG.md exists, create one following [Keep a Changelog](https://keepachangelog.com/) format
2. Read commits since the last tag
3. Group by Conventional Commits type:
   - **Features** (feat:)
   - **Bug Fixes** (fix:)
   - **Performance** (perf:)
   - **Documentation** (docs:)
   - **Refactors** (refactor:)
   - **Chores** (chore:, build:, ci:)
4. Add a new section at the top: `## [Unreleased]` or `## [X.Y.Z] - YYYY-MM-DD`
5. Each entry: brief description, no commit hash unless useful
6. Commit: `chore(changelog): update for [version]`
