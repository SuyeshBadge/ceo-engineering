---
name: bug
description: Bug fix with reproduction test. Use for reported bugs.
---

## Bug report
$ARGUMENTS

## Pipeline

1. **REPRODUCE** — write a failing test that demonstrates the bug
2. **SCOUT** — spawn `scout` to find the relevant code
3. **FIX** — spawn `builder` to make the test pass (smallest change)
4. **VERIFY** — spawn `tester` to confirm fix + no regressions
5. **LOOP** — if tests fail, return to step 3 (cap 4 iterations)
6. **SHIP** — run `/commit`
7. **REPORT** — root cause + fix + tests

## Anti-patterns
- Fixing without a test (you can't verify the fix)
- Changing tests to match buggy behavior (the bug is the bug, not the test)
- Large refactors during a bug fix
