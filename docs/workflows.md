# Workflows — End-to-End Recipes

Common engineering workflows, from simple to complex. Each recipe shows what to type, what the system does, and what to expect.

---

## Table of Contents

1. [Daily standup](#1-daily-standup)
2. [Bug fix workflow](#2-bug-fix-workflow)
3. [Feature implementation](#3-feature-implementation)
4. [Pull request lifecycle](#4-pull-request-lifecycle)
5. [Code review (yours)](#5-code-review-yours)
6. [Code review (someone else's)](#6-code-review-someone-elses)
7. [Merge conflict resolution](#7-merge-conflict-resolution)
8. [Release a version](#8-release-a-version)
9. [Hotfix a production incident](#9-hotfix-a-production-incident)
10. [Refactor a module](#10-refactor-a-module)
11. [Security audit](#11-security-audit)
12. [Investigate a slow test](#12-investigate-a-slow-test)
13. [Onboard to a new codebase](#13-onboard-to-a-new-codebase)
14. [Greenfield side project](#14-greenfield-side-project)
15. [End-of-day cleanup](#15-end-of-day-cleanup)

---

## 1. Daily standup

**What you say:**
```
> /metrics
```

**What the system does:**
- Shows token usage for the week
- Cost per task
- Success rate
- Most expensive tasks

**What you learn:**
- Are you on track for the month?
- Which tasks are taking longer than expected?
- Are there patterns (time of day, task type)?

**Follow-up:**
```
> Run /clean — delete branches merged last week
> Show me my open PRs: @github
```

---

## 2. Bug fix workflow

**Scenario:** User reports a bug.

**Step 1: Investigate**
```
> /bug "Users report being logged out after 5 minutes"
```

**What happens:**
1. CEO writes a failing test that reproduces the bug
2. CEO delegates to scout to find the relevant code
3. CEO delegates to builder to fix it
4. CEO delegates to tester to verify
5. CEO reports root cause + fix + tests

**Step 2: Verify the report**
- Read the report
- Check the diff
- Check the test

**Step 3: Commit**
```
> /commit
```

**Step 4: Push and PR**
```
> /pr
```

**Total time:** 3-5 minutes for a simple bug, 15-20 for a complex one.

---

## 3. Feature implementation

**Scenario:** Add a new feature.

**Step 1: Plan**
```
> /feature "add a /logout endpoint that clears the session cookie"
```

For complex features, the CEO will:
1. Spawn scout to map relevant code
2. Spawn architect to design the approach
3. Show you the plan

**Step 2: Confirm or refine**
```
> That plan looks good, go
```
or
```
> Skip the audit log for now, just do the basic version
```

**Step 3: Watch the work**
The CEO delegates:
- scout → architect → builder → reviewer+tester → doc-writer
- Each reports back to the CEO
- You see summaries, not implementation

**Step 4: Review the report**
CEO will say something like:
```
✓ Done. 
- src/api/auth.ts:89-102 — new /logout endpoint
- src/middleware/session.ts:42 — clear cookie on logout
- tests/api/auth.test.ts:120-145 — 3 new tests
- All 47 tests pass, typecheck clean
- $0.34 spent
- Ready to commit.
```

**Step 5: Commit and PR**
```
> /commit
> /pr
```

**Total time:** 5-10 minutes for a simple feature, 30-60 for a complex one.

---

## 4. Pull request lifecycle

### Create a PR

```
> /pr
```

The skill:
1. Pushes the branch
2. Generates a title (Conventional Commits)
3. Generates a body (summary, test plan, risks)
4. Creates the PR
5. Returns the URL

### Review feedback arrives

```
> /pr-review https://github.com/org/repo/pull/123
```

The skill:
1. Fetches the diff
2. Delegates to reviewer
3. Outputs verdict + findings

### Address review feedback

```
> Address the review feedback on PR #123
```

The CEO:
1. Reads the comments
2. Spawns builder to fix
3. Spawns tester to verify
4. Reports back

### After approval, merge

```
> Merge PR #123
```

(Or use the GitHub UI — sometimes simpler.)

---

## 5. Code review (yours)

**Scenario:** You want to review uncommitted changes before committing.

```
> /review
```

The skill:
1. Shows the diff
2. Delegates to reviewer
3. Outputs:
   - Verdict: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
   - Blocker / Major / Minor / Praise
   - All with file:line

**Use this:**
- Before every commit (if you want to be thorough)
- After significant changes
- Before opening a PR

**Don't use this for:**
- Trivial changes (typo fixes, one-line edits)
- After the agent has already self-reviewed

---

## 6. Code review (someone else's)

**Scenario:** A teammate opens a PR, you need to review.

```
> /pr-review https://github.com/org/repo/pull/456
```

The skill:
1. Fetches the PR (title, body, diff, files)
2. Delegates to reviewer
3. Outputs:
   - 1-paragraph summary
   - Verdict
   - Findings
   - Test plan check
   - Doc check

**Optional: post a comment**
```
> Post these review comments to the PR
```

The agent will ask for confirmation before posting.

---

## 7. Merge conflict resolution

**Scenario:** `git pull` or `git rebase` produced conflicts.

```
> /merge-conflict
```

The skill:
1. Shows which files conflict
2. For each conflict:
   - Reads the file
   - Identifies which side to keep (or combines)
   - Spawns scout to find related tests
   - Applies the resolution
3. Runs tests
4. Marks resolved
5. Continues the rebase/merge

**For complex conflicts:**
The agent may ask you to decide which version to keep. You can also say:
```
> Take the version from main for this file
> Take my version for that file
> Combine them
```

---

## 8. Release a version

**Scenario:** You're ready to cut a release.

**Step 1: Update the changelog**
```
> /changelog
```

**Step 2: Cut the release**
```
> /release
```

The skill:
1. Proposes a SemVer bump based on commits
2. Asks you to confirm
3. Updates version in package.json / pyproject.toml
4. Updates CHANGELOG.md
5. Commits
6. Tags
7. Pushes
8. Optionally creates a GitHub release

**Step 3: Verify**
```
> @github show me the new release
```

---

## 9. Hotfix a production incident

**Scenario:** Production is down. You need a fix NOW.

**Step 1: Create the hotfix branch**
```
> /hotfix
```

The skill:
1. Creates `hotfix/<short-desc>` from main
2. Pushes immediately

**Step 2: Fix the bug**
```
> /bug "users getting 500 on /api/orders, started 10 minutes ago"
```

The CEO:
1. Writes a repro test
2. Fixes the issue
3. Verifies the fix
4. Reports

**Step 3: Get it merged and deployed FAST**
```
> Open a PR for hotfix/orders-500
```
```
> /pr
```

Then merge and deploy:
```
> Deploy the hotfix
```

(Or do it manually — the agent can help with the deploy command but confirm with you.)

---

## 10. Refactor a module

**Scenario:** You want to clean up code without changing behavior.

**Step 1: Define the scope**
```
> /refactor "extract user validation logic from auth.ts into a separate validators/user.ts module"
```

**Step 2: Watch incremental progress**
The skill:
1. Spawns scout to map the affected code
2. Establishes a test baseline
3. Spawns builder for each small chunk
4. Runs tests after each chunk
5. Spawns reviewer at the end

**Critical rule:** tests must stay green throughout. If a refactor breaks tests, the agent reverts that chunk and asks you how to proceed.

**Step 3: Commit in small pieces**
```
> /commit
# Commit 1: extract email validator
# Commit 2: extract password validator
# Commit 3: update imports
# Commit 4: remove dead code
```

(One commit per logical change, not one big commit.)

---

## 11. Security audit

**Scenario:** You touched auth/payments/PII code. Audit it.

```
> /security
```

The skill:
1. Fetches the diff
2. Delegates to security subagent
3. Outputs:
   - Trust boundaries
   - Critical findings (with CWE refs)
   - High / Medium findings
   - Threats considered and rejected

**When to use:**
- Before merging any auth/payment/PII code
- After a security incident
- Periodically on sensitive modules

**If findings are reported:**
```
> Fix the critical security findings
```

The CEO will spawn builder for each fix, then re-run /security to verify.

---

## 12. Investigate a slow test

**Scenario:** A test takes 30 seconds. Why?

**Step 1: Find the slow test**
```
> /agent scout
> Find tests in this repo that take >5 seconds
```

**Step 2: Investigate**
```
> /agent builder
> Profile the slowOrderCreation test and tell me what's taking so long
```

**Step 3: Optimize**
```
> Speed it up
```

**Step 4: Verify**
```
> /test
```

---

## 13. Onboard to a new codebase

**Scenario:** You just joined a new team. Understand the codebase fast.

**Step 1: Map the structure**
```
> /agent scout
> Map the entire codebase. What are the main modules? Where does each business capability live?
```

**Step 2: Read the docs**
```
> Read @README.md and @docs/ and summarize the architecture
```

**Step 3: Find the critical paths**
```
> /agent scout
> What are the 5 most important files in this repo? Why?
```

**Step 4: Understand the tests**
```
> /agent scout
> How are tests organized? What's the test philosophy? Run /test to see what passes
```

**Step 5: Find the gotchas**
```
> /agent scout
> What are the weird parts of this codebase? Things that surprised you? Things that don't follow the obvious pattern?
```

**Total time:** 30-60 minutes for a thorough understanding.

---

## 14. Greenfield side project

**Scenario:** You want to build a side project fast.

```
> /mvp "a SaaS landing page with email capture, pricing section, and Stripe checkout"
```

**What happens:**
1. The system creates `AGENT.md`, `fix_plan.md`, `PROMPT.md`, `specs/`
2. Runs the Ralph loop in the background
3. The loop:
   - Reads the prompt
   - Picks the most important item
   - Implements it
   - Tests it
   - Updates the plan
   - Repeats
4. Stops when: all done, cost cap hit, time cap hit, you stop it

**Monitor:**
```bash
tail -f ~/.config/opencode/logs/ralph-$(date +%Y%m%d).log
```

**Stop:**
```bash
cd /your/project
rm .ralph-stop
```

**Iterate:**
- The agent updates `AGENT.md` with what it learned
- Edit `fix_plan.md` to add or reorder items
- Edit `PROMPT.md` to refine the prompt
- Resume: `~/.config/opencode/loops/ralph.sh`

---

## 15. End-of-day cleanup

**Step 1: Check what's open**
```
> @github list my open PRs
> @github list my assigned issues
```

**Step 2: Review any pending work**
```
> /review
```

**Step 3: Commit anything outstanding**
```
> /commit
```

**Step 4: Sync with main**
```
> /sync
```

**Step 5: Clean up**
```
> /clean
```

**Step 6: Tomorrow's setup**
```
> /metrics
# (Glance at the dashboard)
```

**Total time:** 5-10 minutes.

---

## Bonus: Custom workflows

You can chain skills together in a single prompt:

```
> Fix the bug in /api/orders, write a test, commit it, open a PR, and notify #engineering
```

The CEO delegates to:
- bug skill (which uses scout, builder, tester)
- commit skill
- pr skill
- a notification (via MCP or hook)

All in one go.

---

## Patterns to remember

| Pattern | When | Command |
|---|---|---|
| Quick check | "Is X done?" | `/test` or `/agent scout` |
| Single change | One specific thing | `/commit` or direct `builder` |
| Investigation | "Why is X broken?" | `/bug` (or `/agent scout`) |
| New work | "Add feature X" | `/feature` |
| Cleanup | "Make this nicer" | `/refactor` |
| Validation | "Is this safe to ship?" | `/review` and `/security` |
| Documentation | "What does X do?" | `/explain` or `/doc` |
| Fire-and-forget | "Build me X" | `/mvp` |
| Roll out | "Ship it" | `/release` |
| Daily | "What's my status?" | `/metrics` |
