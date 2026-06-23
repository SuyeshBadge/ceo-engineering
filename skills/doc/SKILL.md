---
name: doc
description: Generate or update documentation for the recent changes. Use after a feature lands.
allowed-tools: Read, Edit, Write, WebFetch
---

## Recent diff
!`git diff HEAD~1 HEAD --name-only 2>/dev/null || git diff --name-only`

## Instructions

Delegate to the **doc-writer** subagent with the diff above.

Output:
- **Docs updated**: <file + 1-line change>
- **Docs left alone**: <file + reason>
- **Recommendations**: <1 thing the user should add manually>

Focus on:
- README updates for new features
- JSDoc / docstrings for new public APIs
- Inline comments only for non-obvious logic
- API docs if the project has them (e.g. docs/api.md, OpenAPI)
