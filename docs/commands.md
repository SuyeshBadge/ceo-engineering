# Daily Commands — Reference

23 skills, grouped by when you reach for them.

## Commit & Ship

### `/commit`
Stage and commit with Conventional Commits. Runs pre-commit checks. One commit per logical change.
- Type: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `build`, `ci`
- Subject ≤ 72 chars, imperative mood

### `/pr`
Open a PR for the current branch.
- Pushes branch, creates PR with title/body/reviewers/labels
- Confirms naming convention

### `/pr-review <url|number>`
Review someone else's PR.
- Fetches the diff, delegates to `reviewer` subagent
- Optionally posts a comment (asks first)

### `/review`
Review your uncommitted changes.
- Staged + unstaged diff → reviewer subagent
- Output: Verdict, Blocker/Major/Minor/Praise

### `/merge-conflict`
Resolve merge conflicts intelligently.
- Reads conflict markers, determines intent
- Spawns scout to find related tests before resolving
- Applies fix, runs tests, continues rebase/merge

## Test & Verify

### `/test`
Run targeted tests for the recent diff.
- Detects test command (pnpm/npm/pytest/go/cargo)
- Runs only the relevant files
- Reports pass/fail/skip + time

### `/lint`
Run the project's linter on changed files.
- Detects linter (eslint/ruff/golangci-lint/clippy)
- Auto-fixes what it can

### `/typecheck`
Run TypeScript / mypy / pyright.
- Reports errors with file:line
- Suggests fix for each

### `/format`
Format code in the working tree.
- Detects formatter (prettier/black/gofmt/rustfmt/shfmt)
- Per-file, fast

### `/security`
Security audit of the recent changes.
- Delegates to `security` subagent
- Output: Trust boundaries, Critical/High/Medium findings with CWE refs

## Branch & Sync

### `/branch <name>`
Create a properly-named branch.
- Detects convention from recent branches
- Defaults to `<type>/<short-desc>`

### `/sync`
Sync with the default branch (rebase preferred).
- Fetches, rebases, force-pushes with `--force-with-lease`
- Delegates to `/merge-conflict` on conflicts

### `/clean`
Delete local merged branches.
- Lists candidates, asks for confirmation
- `-d` for merged, `-D` for stale (asks)

## Release & Version

### `/changelog`
Update CHANGELOG.md with recent merged changes.
- Groups by Conventional Commits type
- Follows Keep a Changelog format

### `/release`
Cut a release: bump version, draft notes, push tag.
- Proposes SemVer bump from commit log
- Updates version, changelog, tags, optionally creates GitHub release

### `/hotfix`
Create an emergency fix branch from main.
- For production incidents
- Pushes immediately, delegates to `/bug`

## Understand & Document

### `/explain <file|function>`
Explain a file, function, or concept.
- Reads in full, traces call graph 1 level
- Outputs: purpose, inputs/outputs, how it works, edge cases, related

### `/doc`
Generate or update documentation.
- Delegates to `doc-writer` subagent
- Updates README, JSDoc, inline comments

## Big Work

### `/feature <description>`
Full feature pipeline (8-10 subagent invocations).
- scout → architect (if complex) → builder → reviewer+tester → doc-writer → commit
- Reports in CEO language

### `/bug <description>`
Bug fix with reproduction test.
- Writes failing test first, then fix
- Verifies no regressions

### `/refactor <scope>`
Behavior-preserving refactor.
- Tests must stay green throughout
- Small, verifiable chunks

## Fire & Forget

### `/mvp <idea>`
Ralph Wiggum persistent loop for greenfield.
- Sets up `AGENT.md`, `fix_plan.md`, `PROMPT.md`, `specs/`
- Runs prompt in a loop with cost/time cap
- Use for greenfield, side projects, weekends
- Don't use in existing codebases

### `/metrics`
Show session cost, throughput, loop health.
- This session: tokens in/out/cached, cost
- By agent: calls, tokens, cost table
- This week: total, avg per task, success rate
