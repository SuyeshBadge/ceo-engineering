---
description: Behavior-preserving refactor. Use for code cleanup that doesn't change behavior.
agent: reviewer
---

## Refactor scope
$ARGUMENTS

## Pipeline

1. **SCOUT** — map the affected code
2. **TEST BASELINE** — confirm existing tests pass (this is your safety net)
3. **PLAN** — small, verifiable chunks
4. **APPLY** — spawn `builder` for each chunk
5. **VERIFY** — after each chunk, re-run tests; if they fail, revert that chunk
6. **LOOP** — continue until all chunks done
7. **REVIEW** — spawn `reviewer` to confirm no behavior change
8. **SHIP** — run `/commit` (separate from feature work)

## Golden rule
**Tests must stay green throughout.** If a refactor breaks tests, the refactor is wrong (or the tests were wrong — but the latter is a separate fix).

## Anti-patterns
- Combining refactor with feature/fix (split into two commits)
- Big-bang refactors (do small chunks)
- "Drive-by" refactors (PR description should be one thing only)
