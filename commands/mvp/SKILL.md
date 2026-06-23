---
name: mvp
description: Fire-and-forget build of a greenfield MVP using the Ralph Wiggum persistent loop.

## Idea
$ARGUMENTS

## Setup

1. Create the project directory if needed
2. Create these files:
   - `AGENT.md` — how to build/test/run (will be tuned over time)
   - `fix_plan.md` — prioritized TODO list (the agent updates this)
   - `PROMPT.md` — the prompt fed into the loop
   - `specs/` — one .md per module/feature
3. PROMPT.md template:

```
You are building: $ARGUMENTS

Read AGENT.md for build/test commands. Read fix_plan.md for the current TODO.
Pick the most important un-done item. Implement it. Update fix_plan.md.
After implementing, run the tests for that unit of code that was improved.
Do NOT implement placeholders or minimal implementations. Do it fully.
Before making changes, search the codebase (don't assume not implemented).
Use subagents for read operations. Think hard.
After green: commit and update AGENT.md with build learnings.
```

4. Run: `~/.config/opencode/loops/ralph.sh` in the project directory

## Cost cap
$ARGUMENTS may include a budget like "$5" or "30 minutes" — pipe that to the loop's --cost-cap / --time-cap

## When to use
- Greenfield side projects
- Weekend experiments
- Bootstrapping a new service

## When NOT to use
- Existing codebases (Huntley: "no way in heck")
- Production systems
- Anything where you'd notice $297 of token spend
