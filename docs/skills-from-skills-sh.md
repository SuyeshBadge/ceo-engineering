# Curated Skills from skills.sh

The CEO Engineering System ships with a curated selection of high-quality skills from [skills.sh](https://skills.sh). These complement the 23 built-in daily-work skills.

## TL;DR

**Default install includes skills from these repos:**

| Category | Repos | Skills gained |
|---|---|---|
| **Process** | `obra/superpowers` | 14 skills (TDD, debugging, planning, subagent patterns) |
| **TypeScript** | `mattpocock/skills` | 13+ skills (grill, tdd, architecture, prototype) |
| **Caveman** | `juliusbrussee/caveman` | 7 skills (terse prompting family) |
| **Frontend** | `vercel-labs/agent-skills`, `vercel-labs/next-skills`, `shadcn/ui`, `anthropics/skills` | ~10 skills (React, Next.js, shadcn, design) |
| **Backend** | `supabase/agent-skills`, `xixu-me/skills` | ~8 skills (Postgres, GitHub Actions) |
| **Design** | `pbakaus/impeccable`, `leonxlnx/taste-skill`, `sleekdotdesign/agent-skills`, `nextlevelbuilder/ui-ux-pro-max-skill`, `arvindrk/extract-design-system`, `coreyhaines31/marketingskills` | ~15 skills (UI/UX polish, taste) |

**Total:** ~70+ curated skills from skills.sh, on top of the 23 built-in.

---

## The categories

### 1. Process (obra/superpowers) — Tier 1, default

**The most important set.** 14 skills covering the full engineering process. Used by the CEO agent to plan, debug, verify, and ship.

| Skill | What | When to use |
|---|---|---|
| `brainstorming` | Socratic exploration of an idea | Before any non-trivial work |
| `writing-plans` | Write a structured plan | Complex features, refactors |
| `executing-plans` | Execute a plan with checkpoints | When you have a plan |
| `test-driven-development` | Red-green-refactor discipline | New features, bug fixes |
| `systematic-debugging` | Reproduce-then-fix debugging | Bug reports |
| `verification-before-completion` | Confirm before declaring done | Always |
| `subagent-driven-development` | Pattern for subagent orchestration | When using multiple agents |
| `dispatching-parallel-agents` | Spawn N agents in parallel | Large migrations, search |
| `using-git-worktrees` | Worktree isolation for agents | Long-running parallel work |
| `using-superpowers` | The meta-skill — when to use what | Start of session |
| `requesting-code-review` | Ask for code review | Pre-commit, pre-PR |
| `receiving-code-review` | Handle review feedback gracefully | After review |
| `finishing-a-development-branch` | Ship it — merge, tag, cleanup | End of feature |
| `writing-skills` | Author new skills | Customizing the system |

**Install:** `npx skills add obra/superpowers`

### 2. TypeScript (mattpocock/skills) — Tier 1, default

Matt Pocock's TypeScript-focused skills. Sharp tools for modern JS/TS engineers.

| Skill | What |
|---|---|
| `tdd` | Test-driven development for TS |
| `grill-me` | Socratic grilling — defends the design |
| `grill-with-docs` | Grilling grounded in documentation |
| `improve-codebase-architecture` | Architecture review |
| `to-prd` | Convert an idea to a PRD |
| `to-issues` | Break a PRD into GitHub issues |
| `triage` | Triage incoming issues |
| `diagnose` | Diagnose a bug |
| `write-a-skill` | Author skills in Matt's style |
| `zoom-out` | Step back and see the big picture |
| `caveman` | Terse prompting |
| `handoff` | Hand off work to a teammate |
| `prototype` | Rapid prototyping |
| `setup-matt-pocock-skills` | Set up the family |

**Install:** `npx skills add mattpocock/skills`

### 3. Caveman (juliusbrussee/caveman) — Tier 1, default

The full Caveman family. Terse, token-efficient communication.

| Skill | What |
|---|---|
| `caveman` | Main caveman prompting style |
| `caveman-commit` | Caveman-style commit messages |
| `caveman-review` | Caveman-style code review |
| `caveman-compress` | Compress text to caveman style |
| `cavecrew` | Multi-agent caveman (caveman + subagents) |
| `caveman-stats` | Stats on caveman-style responses |
| `caveman-help` | Help with caveman prompting |

**Install:** `npx skills add juliusbrussee/caveman`

### 4. Frontend — Tier 1, default

| Repo | What you get |
|---|---|
| `vercel-labs/agent-skills` | `web-design-guidelines`, `vercel-react-best-practices`, `agent-browser`, `vercel-composition-patterns`, `vercel-react-native-skills` |
| `vercel-labs/next-skills` | `next-best-practices` |
| `shadcn/ui` | `shadcn` — shadcn/ui patterns |
| `anthropics/skills` | `frontend-design`, `pdf`, `docx`, `pptx`, `xlsx`, `skill-creator` |

**Install:**
```bash
npx skills add vercel-labs/agent-skills
npx skills add vercel-labs/next-skills
npx skills add shadcn/ui
npx skills add anthropics/skills
```

### 5. Backend — Tier 1, default

| Repo | What you get |
|---|---|
| `supabase/agent-skills` | `supabase`, `supabase-postgres-best-practices` |
| `xixu-me/skills` | `github-actions-docs`, `develop-userscripts`, `openclaw-secure-linux-cloud`, `xget`, `xdrop`, `tzst` |

**Install:**
```bash
npx skills add supabase/agent-skills
npx skills add xixu-me/skills
```

### 6. Design polish — Tier 1, default

| Repo | What you get |
|---|---|
| `pbakaus/impeccable` | UI/UX polish (Emil Kowalski-inspired) |
| `leonxlnx/taste-skill` | 8 taste variants: design-taste-frontend, high-end-visual-design, redesign-existing-projects, minimalist-ui, full-output-enforcement, industrial-brutalist-ui, stitch-design-taste, gpt-taste |
| `sleekdotdesign/agent-skills` | sleek-design-mobile-apps |
| `nextlevelbuilder/ui-ux-pro-max-skill` | ui-ux-pro-max |
| `arvindrk/extract-design-system` | Extract design system from any site |
| `coreyhaines31/marketingskills` | seo-audit, copywriting |

**Install:**
```bash
npx skills add pbakaus/impeccable
npx skills add leonxlnx/taste-skill
npx skills add sleekdotdesign/agent-skills
npx skills add nextlevelbuilder/ui-ux-pro-max-skill
npx skills add arvindrk/extract-design-system
npx skills add coreyhaines31/marketingskills
```

### 7. Utilities — Tier 2, opt-in

| Repo | What |
|---|---|
| `scrapegraphai/just-scrape` | Web scraping with natural language |
| `roin-orca/skills` | Simple skill authoring |

Set `install: true` in `skills-manifest.json` to include.

---

## Customizing what's installed

Edit `skills-manifest.json` at the root of this repo. The structure is:

```json
{
  "categories": {
    "process": {
      "install": true,    // ← change to false to skip
      "skills": [
        { "name": "obra/superpowers" }
      ]
    }
  }
}
```

Set `install: false` to skip a category. Then re-run setup:

```bash
curl -fsSL https://raw.githubusercontent.com/SuyeshBadge/ceo-engineering/main/setup.sh | bash
```

---

## How the install works

`setup.sh` reads `skills-manifest.json` and runs `npx skills add <owner/repo>` for each tier-1 category. The skills.sh CLI installs the skills into:

- `~/.config/opencode/skills/<skill-name>/` (opencode)
- `~/.claude/skills/<skill-name>/` (Claude Code)

Both editors read the same standard paths, so a skill installed once is available everywhere.

If `npx skills add` fails (network, package not found), the setup falls back to a `git clone` of the repo and looks for `SKILL.md` files inside. If neither works, the skill is skipped with a warning.

---

## Skipped on purpose

These are in skills.sh but we don't install by default:

- **Azure skills** (`microsoft/azure-skills/*`) — too specific. Install if you use Azure.
- **Lark/Feishu skills** — only useful in Lark-using orgs.
- **Video/image generation** (`agentspace-so/*`, `doany-ai/*`, `runcomfy-com/*`) — off-topic for engineering.
- **Paper reproduction** (`lllllllama/ai-paper-reproduction-skill`) — specialized ML research.

Install any of these manually with:
```bash
npx skills add <owner/repo>
```

---

## Adding new categories

To add a new category to the curated set:

1. Add it to `skills-manifest.json`:
```json
{
  "categories": {
    "my-category": {
      "description": "What this is for",
      "tier": 1,
      "install": true,
      "skills": [
        { "name": "owner/repo", "description": "..." }
      ]
    }
  }
}
```

2. Re-run setup.

3. (Optional) Update this doc to describe the new category.

---

## Conflict resolution

If a skill from skills.sh has the same name as a built-in one, the skills.sh version wins (installed last). To force the built-in version:

```bash
# Remove the skills.sh one
rm -rf ~/.config/opencode/skills/<conflicting-skill>

# Restore from our built-in
cp -r /path/to/ceo-engineering/skills/<name>/ ~/.config/opencode/skills/
```

Or, more cleanly, edit `skills-manifest.json` to set that category's `install: false`.

---

## See also

- [skills.sh](https://skills.sh) — the full directory
- [docs/commands.md](commands.md) — the 23 built-in daily commands
- [docs/efficiency-mcps.md](efficiency-mcps.md) — RTK, Octocode, Caveman
- [docs/architecture.md](architecture.md) — system design
