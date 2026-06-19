---
name: vault-mist
description: Search, create, and manage personal repo notes (CONTEXT, ADRs, tasks/issues) in the mist Obsidian vault. Use for personal repos like dots.factory, nebular-grid. Works through obsidian-cli — Obsidian must be running.
---

# Mist Vault — Personal Coding

The mist vault is the **canonical store for per-repo metadata** of personal projects: CONTEXT, ADRs, tasks, investigation notes. The repo itself stays clean — no `docs/adr/` clutter.

## Vault location

`~/vaults/mist`

## Structure

Two folders at vault root:

```
Coding/
  dots.factory.md                              # main repo note (CONTEXT lives here)
  dots.factory - ADR 001 - use den.md          # ADRs as standalone notes
  dots.factory - ADR 002 - aspect placement.md
  nebular-grid.md
  nebular-grid - ADR 001 - tauri.md

Tasks/
  2026-06-19 1430 dots.factory - add pi agent.md   # task/feature/bug notes
  2026-06-19 1445 dots.factory - fix zsh startup.md
```

- **`Coding/`** — CONTEXT and ADR notes. Organisation comes from frontmatter, not subfolders.
- **`Tasks/`** — one note per task/issue/feature, managed by the TaskNotes plugin. Filename pattern: `YYYY-MM-DD HHmm <project> - <slug>.md`.

## Frontmatter convention

### Coding/ notes (CONTEXT and ADRs)

```yaml
---
project: dots.factory          # repo name (required)
type: context | adr            # what kind of note (required)
adr-number: 001                # for type=adr only
status: active | archived
tags: [coding, project/dots.factory]
---
```

### Tasks/ notes (TaskNotes plugin)

```yaml
---
title: dots.factory - Add pi agent
aliases:
  - dots.factory - Add pi agent
tags:
  - task
  - project/dots.factory
type: Task | Feature | Bug
status: open | in-progress | done | cancelled
priority: 1 - Critical | 2 - High | 3 - Medium | 4 - Low
created: 2026-06-19
due:
scheduled:
contexts:
  - "[[dots.factory]]"
projects: []
project: "[[dots.factory]]"    # wikilink to project CONTEXT note
issue:                         # GitHub issue number if linked
id: 2026-06-19 1430 dots.factory - add pi agent
---
```

Key rules:
- `tags` must include `task` (TaskNotes detection) and `project/<name>` (for filtering)
- `title` and `aliases` are identical — both required for TaskNotes to display correctly
- `project` is a wikilink to the project's CONTEXT note in `Coding/` — enables backlinks and Bases queries
- `contexts` mirrors the same link for TaskNotes' own context filtering

## Authority

- **mist vault `Tasks/`** is authoritative for: task status, priority, scheduling (vault-native tracking)
- **mist vault `Coding/`** is authoritative for: CONTEXT, ADRs, decisions
- **GitHub Issues** (optional): link via `issue:` frontmatter field if a task has a corresponding GH issue

## Prerequisite

`obsidian-cli` requires Obsidian to be running. If commands fail with "unable to find Obsidian", remind the user to open Obsidian first.

## Workflows

### Find the project's main note (CONTEXT)

The main note name equals the repo name (e.g. `dots.factory`):

```bash
obsidian-cli vault=mist read file="dots.factory"
```

### List all tasks for a project

```bash
obsidian-cli vault=mist search query="project/dots.factory" path=Tasks
# or by filename pattern:
ls ~/vaults/mist/Tasks/ | grep "dots.factory"
```

### List open tasks for a project

```bash
obsidian-cli vault=mist search query="project/dots.factory status: open" path=Tasks
```

### List all ADRs for a repo

```bash
obsidian-cli search:context query='project: dots.factory' path=Coding | grep "type: adr"
# Or by name pattern (faster):
ls ~/vaults/mist/Coding/ | grep "^dots.factory - ADR"
```

### Create a new ADR

```bash
# Next ADR number
ls ~/vaults/mist/Coding/ | grep "^dots.factory - ADR" | sort -V | tail -1

# Create the file
cat > "$HOME/vaults/mist/Coding/dots.factory - ADR 003 - flake-parts.md" <<'EOF'
---
project: dots.factory
type: adr
adr-number: 003
status: active
tags: [coding, project/dots.factory, adr]
---

# ADR 003 — Flake Parts

**Date**: YYYY-MM-DD
**Status**: Accepted

## Context
...

## Decision
...

## Consequences
...

## Alternatives considered
...
EOF
```

### Create a new task

Filename: `YYYY-MM-DD HHmm <project> - <slug>.md` under `Tasks/`.

```bash
DATESTAMP=$(date +"%Y-%m-%d %H%M")
cat > "$HOME/vaults/mist/Tasks/${DATESTAMP} dots.factory - add-pi-agent.md" <<'EOF'
---
title: dots.factory - Add pi agent
aliases:
  - dots.factory - Add pi agent
tags:
  - task
  - project/dots.factory
type: Feature
status: open
priority: 3 - Medium
created: 2026-06-19
due:
scheduled:
contexts:
  - "[[dots.factory]]"
projects: []
project: "[[dots.factory]]"
issue:
id: 2026-06-19 1430 dots.factory - add-pi-agent
---

## Description

...

## Acceptance Criteria

- [ ] ...
EOF
```

If there's a linked GitHub issue, fetch it first and populate `issue:` and the description:

```bash
gh issue view 42 --repo trash-panda-v91-beta/dots.factory
```

### Find related notes (backlinks)

```bash
obsidian-cli backlinks file="dots.factory"
```

### Search tasks by keyword

```bash
obsidian-cli vault=mist search query='pi agent' path=Tasks
```

### When a skill asks for ADRs / CONTEXT for the current repo

1. Identify the repo from `git remote -v` or `basename "$(git rev-parse --show-toplevel)"`
2. Read `Coding/<repo-name>.md` for CONTEXT
3. Search `Coding/` for files matching `<repo-name> - ADR ` for the ADR set

If neither exists, the project hasn't been onboarded — offer to create the CONTEXT note.
