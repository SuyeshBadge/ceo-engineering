---
name: release
description: Cut a release: bump version, draft notes, push tag.
disable-model-invocation: true
allowed-tools: Bash(git:*), Bash(gh:*), Read, Edit, Write
---

## Recent merged PRs since last tag
!`git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --oneline`

## Current version
!`node -p "require('./package.json').version" 2>/dev/null || cat VERSION 2>/dev/null || echo "unknown"`

## Instructions

1. Propose a SemVer bump based on commit log:
   - `feat:` commits → minor
   - `fix:` / `perf:` commits → patch
   - `BREAKING CHANGE:` in footer → major
2. Ask the user to confirm the bump (always)
3. Update version in: package.json, VERSION, pyproject.toml, etc.
4. Update CHANGELOG.md (delegate to `/changelog` if not done)
5. Commit: `chore(release): vX.Y.Z`
6. Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
7. Push: `git push && git push --tags`
8. Optionally create a GitHub release: `gh release create vX.Y.Z --generate-notes`
9. Report: version, tag, release URL
