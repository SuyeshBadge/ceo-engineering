---
name: explain
description: Explain a file, function, or concept from the codebase. Use when learning unfamiliar code.

## Target
$ARGUMENTS

## Instructions

1. If `$ARGUMENTS` is a path, read the file in full
2. If it's a symbol name, find its definition with Grep
3. Trace the call graph up to one level for context
4. Explain in this order:
   - **Purpose** (one sentence)
   - **Inputs / Outputs** (signature + types)
   - **How it works** (step by step, max 5 steps)
   - **Edge cases / gotchas**
   - **Where else it's used** (file:line refs)
5. Use diagrams (ASCII or mermaid) for control flow when >3 branches
6. End with a "Related" section: 1-3 similar files
