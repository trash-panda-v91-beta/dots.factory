---
name: vault-mist
description: Search, create, and manage personal repo notes (CONTEXT, ADRs, issues, investigations) in the mist Obsidian vault. Use for personal repos like dots.factory, nebular-grid. Works through obsidian-cli — Obsidian must be running.
---

# Mist Vault — Personal Coding

The mist vault is the **canonical store for per-repo metadata** of personal projects: CONTEXT, ADRs, ticket enrichment, investigation notes. The repo itself stays clean — no `docs/adr/` clutter.

## Vault location

`~/vaults/mist`

## Structure

All coding-related notes live in **`Coding/`** at the vault root, flat:

```
Coding/
  dots.factory.md                              # main repo note (CONTEXT lives here)
  dots.factory - ADR 001 - use den.md          # ADRs as standalone notes
  dots.factory - ADR 002 - aspect placement.md
  dots.factory - add pi agent.md               # issue/feature notes
  nebular-grid.md
  nebular-grid - ADR 001 - tauri.md
```

Organization comes from **frontmatter**, not folders.

## Frontmatter convention

Every note in `Coding/` has:

```yaml
---
project: dots.factory          # repo name (required)
type: context | adr | issue    # what kind of note (required)
adr-number: 001                # for type=adr only
issue: 42                      # GitHub issue number, for type=issue
status: active | archived      # optional
tags: [coding, project/dots.factory]
---
```

## Authority

- **GitHub Issues** is authoritative for: status, assignee, labels, milestones
- **mist vault** is authoritative for: CONTEXT, ADRs, investigation notes, decisions, links

## Prerequisite

`obsidian-cli` requires Obsidian to be running. If commands fail with "unable to find Obsidian", remind the user to open Obsidian first.

## Workflows

### Find the project's main note (CONTEXT)

The main note name equals the repo name (e.g. `dots.factory`):

```bash
# Read the CONTEXT note
obsidian-cli property:read name=type file="dots.factory"
obsidian-cli search query="project: dots.factory" path=Coding
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

### Start notes for a new GitHub issue

```bash
gh issue view 42 --repo trash-panda-v91-beta/dots.factory
```

Then create `Coding/dots.factory - <issue-slug>.md`:

```markdown
---
project: dots.factory
type: issue
issue: 42
status: active
tags: [coding, project/dots.factory, issue]
---

# dots.factory#42 — <title>

**GitHub**: [#42](https://github.com/trash-panda-v91-beta/dots.factory/issues/42)

## Investigation
...
```

### Find related notes (backlinks)

```bash
obsidian-cli backlinks file="dots.factory"
```

### Search investigation notes for a keyword

```bash
obsidian-cli search:context query='deadlock' path=Coding
```

### When a skill asks for ADRs / CONTEXT for the current repo

1. Identify the repo from `git remote -v` or `basename "$(git rev-parse --show-toplevel)"`
2. Read `Coding/<repo-name>.md` for CONTEXT
3. Search `Coding/` for files matching `<repo-name> - ADR ` for the ADR set

If neither exists, the project hasn't been onboarded — offer to create the CONTEXT note.
