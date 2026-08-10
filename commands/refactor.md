---
description: Route a behavior-preserving refactor through the CEO controller.
agent: ceo
---

$ARGUMENTS

Pick reversible/local, standard, or risky/irreversible from actual scope and uncertainty; don't mix in unrelated features or fixes. Delegate the refactor to `builder`, which treats behavior preservation as its own acceptance criterion — checking its own `git diff` before/after and confirming the same tests still pass — then gate with `tester`/`reviewer` before reporting done.
